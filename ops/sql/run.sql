-- 거래중 7일 경과 → 자동 판매완료 + 판매자가 되돌릴 수 있게 (2026-11-02)
--
-- 배경: 거래는 카톡에서 끝나고 아무도 사이트에 돌아와 '완료'를 안 누른다.
--       그래서 거래중 글이 영원히 거래중으로 남고, 취소 102 / 완료 15 라는 숫자가 나왔다.
-- 규칙: 구매 신청(Trade.createdAt) 후 7일이 지나도 거래중이면 완료로 간주.
--       판매자 상점에 "자동 완료됨 — 아니면 판매중으로 되돌리기" 안내가 뜬다.

-- 1. 자동 완료 표식 (NULL 이면 사람이 직접 완료한 것)
ALTER TABLE "Trade"   ADD COLUMN IF NOT EXISTS "autoCompletedAt" timestamptz;
ALTER TABLE "Listing" ADD COLUMN IF NOT EXISTS "autoCompletedAt" timestamptz;

-- 2. 자동 완료 (매시 실행). 기존 클라이언트의 수령확인 로직과 같은 효과:
--    Trade→completed(+completedAt), Listing→sold, 같은 구매자-판매자 쌍의 첫 완료면 tradeCount+1
CREATE OR REPLACE FUNCTION auto_complete_stale_trades()
RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  r record;
  n integer := 0;
BEGIN
  FOR r IN
    SELECT t.id AS trade_id, t."listingId", t."buyerId", t."sellerId"
    FROM "Trade" t
    JOIN "Listing" l ON l.id = t."listingId"
    WHERE t.status IN ('active', 'seller_confirmed')
      AND l.status IN ('trading', 'seller_confirmed')
      AND t."createdAt" <= now() - interval '7 days'
  LOOP
    UPDATE "Trade"
       SET status = 'completed', "completedAt" = now(), "autoCompletedAt" = now()
     WHERE id = r.trade_id;

    UPDATE "Listing"
       SET status = 'sold', "autoCompletedAt" = now()
     WHERE id = r."listingId";

    IF NOT EXISTS (
      SELECT 1 FROM "Trade"
       WHERE "buyerId" = r."buyerId" AND "sellerId" = r."sellerId"
         AND status = 'completed' AND id <> r.trade_id
    ) THEN
      UPDATE "User" SET "tradeCount" = coalesce("tradeCount", 0) + 1 WHERE id = r."sellerId";
    END IF;

    n := n + 1;
  END LOOP;
  RETURN n;
END;
$$;

-- 3. 판매자가 되돌리기: 자동 완료된 거래를 취소로, 글을 판매중으로.
--    본인 글만 가능. 자동 완료 때 올린 tradeCount 도 같은 조건으로 되돌린다.
CREATE OR REPLACE FUNCTION revert_auto_completed_listing(p_listing_id text)
RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_owner text;
  v_trade record;
BEGIN
  SELECT "userId" INTO v_owner FROM "Listing" WHERE id = p_listing_id;
  IF v_owner IS NULL THEN
    RAISE EXCEPTION 'listing_not_found';
  END IF;
  IF auth.uid() IS NULL OR v_owner <> auth.uid()::text THEN
    RAISE EXCEPTION 'not_owner';
  END IF;

  SELECT id, "buyerId", "sellerId" INTO v_trade
    FROM "Trade"
   WHERE "listingId" = p_listing_id AND status = 'completed' AND "autoCompletedAt" IS NOT NULL
   ORDER BY "autoCompletedAt" DESC
   LIMIT 1;

  IF v_trade.id IS NOT NULL THEN
    UPDATE "Trade"
       SET status = 'cancelled', "completedAt" = NULL, "autoCompletedAt" = NULL
     WHERE id = v_trade.id;

    IF NOT EXISTS (
      SELECT 1 FROM "Trade"
       WHERE "buyerId" = v_trade."buyerId" AND "sellerId" = v_trade."sellerId"
         AND status = 'completed'
    ) THEN
      UPDATE "User" SET "tradeCount" = GREATEST(coalesce("tradeCount", 0) - 1, 0)
       WHERE id = v_trade."sellerId";
    END IF;
  END IF;

  UPDATE "Listing" SET status = 'active', "autoCompletedAt" = NULL WHERE id = p_listing_id;
  RETURN true;
END;
$$;

REVOKE ALL ON FUNCTION revert_auto_completed_listing(text) FROM public;
GRANT EXECUTE ON FUNCTION revert_auto_completed_listing(text) TO authenticated;

-- 4. 매시 20분에 실행 (같은 이름이면 교체됨)
SELECT cron.schedule('auto-complete-trades', '20 * * * *', $$SELECT auto_complete_stale_trades();$$);

-- 5. 확인: 지금 기준으로 다음 실행에 자동 완료될 거래
\echo ''
\echo '--- 다음 실행 때 자동 완료될 거래 (7일 경과) ---'
SELECT t.id, g.slug AS "게임", t.status AS "거래상태", l.status AS "글상태",
       date_trunc('day', t."createdAt" AT TIME ZONE 'Asia/Seoul')::date AS "신청일",
       (now() - t."createdAt")::interval(0) AS "경과"
FROM "Trade" t
JOIN "Listing" l ON l.id = t."listingId"
JOIN "Game" g ON g.id = l."gameId"
WHERE t.status IN ('active','seller_confirmed')
  AND l.status IN ('trading','seller_confirmed')
  AND t."createdAt" <= now() - interval '7 days'
ORDER BY t."createdAt";

\echo ''
\echo '--- 등록된 cron ---'
SELECT jobname, schedule, command FROM cron.job WHERE jobname LIKE 'auto-%' ORDER BY jobname;
