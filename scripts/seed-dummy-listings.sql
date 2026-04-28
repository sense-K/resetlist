-- ============================================================
-- sold 더미 매물 생성: 원신/스타레일/젠레스/니케 각 30개 = 총 120개
-- 실행 전: Supabase SQL Editor에서 검토 후 ROLLBACK 또는 COMMIT 선택
-- ⚠️  기존 active 매물은 절대 건드리지 않음 (INSERT only)
-- ============================================================

BEGIN;

DO $$
DECLARE
  -- ── 게임 ID ────────────────────────────────────────────────
  GENSHIN_ID  CONSTANT TEXT := 'd4b69d1d-7744-4c62-bd45-925c5bcdf1a6';
  STARRAIL_ID CONSTANT TEXT := '558ec853-4190-49bc-8fcc-f72c304c082a';
  ZZZ_ID      CONSTANT TEXT := 'a7373b76-ee03-4dda-809f-1ccb7c5aa4be';
  NIKKE_ID    CONSTANT TEXT := 'cmnile0mk0003g8cv1pczc9d7';

  -- ── 유저 풀 (5명 라운드로빈) ─────────────────────────────
  users TEXT[] := ARRAY[
    'cmniojabx0000j8cv7mdy7nvv',
    'd0000000-0000-0000-0000-000000000010',
    'd0000000-0000-0000-0000-000000000011',
    '6ebbc246-ddb6-40c8-ad35-4c194f8e361f',
    '2e7ce614-615e-4df3-9cba-4c1a133ae99c'
  ];

  -- ── 가격 풀 ─────────────────────────────────────────────
  prices INT[] := ARRAY[
    9800, 14800, 19800, 24800, 29800, 34800,
    39800, 49800, 59800, 69800, 79800, 89800,
    99800, 119800, 139800, 149800, 179800, 199800,
    249800, 299800
  ];

  -- ── 설명 풀 ─────────────────────────────────────────────
  descs TEXT[] := ARRAY[
    '초기 30연 5성 캐릭 풀돌 계정 판매합니다. 자세한 정보는 톡 주세요.',
    '메인 딜러 + 서포터 풀템 세팅 완료. 즉시 사용 가능.',
    '장기 미접속 정리합니다. 캐릭터 다양함.',
    '휴면 계정 정리. 메인 캐릭 만렙.',
    '이벤트 캐릭터 다수 보유. 카카오톡으로 문의.',
    '서브계정 정리. 리세 추천.',
    '원석/재화 보유. 신규 시작용으로 좋아요.',
    '복귀 유저용 추천. 컨텐츠 진입 가능.',
    '쿨거래 가능. 네고 불가.',
    '인기 한정 캐릭 다수 보유. 급처합니다.',
    '시작 단계부터 육성한 계정. 메인 컨텐츠 클리어.',
    '이벤트 재화 다수 보유. 즉시 사용 가능한 계정입니다.'
  ];

  -- ── 서버 풀 (가중치: Asia 60%, America 25%, Europe 10%, TW/JP 5%) ──
  -- 원신
  genshin_servers TEXT[] := ARRAY[
    'smnvjr6o1tblehb','smnvjr6o1tblehb','smnvjr6o1tblehb',  -- Asia ×6
    'smnvjr6o1tblehb','smnvjr6o1tblehb','smnvjr6o1tblehb',
    'smnvjr1uxn7r6xm','smnvjr1uxn7r6xm','smnvjr1uxn7r6xm',  -- America ×3 (≈25%)
    'smnvjr4jdvxkd94',                                        -- Europe ×1 (≈10%)
    'smnvjr99mb6ryh1'                                         -- TW ×1  (≈5%)
  ];
  -- 스타레일
  starrail_servers TEXT[] := ARRAY[
    'smoab8bdt5sxmnb','smoab8bdt5sxmnb','smoab8bdt5sxmnb',
    'smoab8bdt5sxmnb','smoab8bdt5sxmnb','smoab8bdt5sxmnb',
    'smoab89mlh97yaz','smoab89mlh97yaz','smoab89mlh97yaz',
    'smoab8cvasl94kb',
    'smoab8ejkntpuy9'
  ];
  -- 젠레스
  zzz_servers TEXT[] := ARRAY[
    'smnwnfwrwz3jxlb','smnwnfwrwz3jxlb','smnwnfwrwz3jxlb',
    'smnwnfwrwz3jxlb','smnwnfwrwz3jxlb','smnwnfwrwz3jxlb',
    'smnwnfur4jdf5a7','smnwnfur4jdf5a7','smnwnfur4jdf5a7',
    'smnwnfyd6r1zn1o',
    'smnwng04inn8fhx'
  ];
  -- 니케 (한국 60%, 글로벌 30%, 일본 10%)
  nikke_servers TEXT[] := ARRAY[
    'cmnile12g000gg8cvbt83fddh','cmnile12g000gg8cvbt83fddh','cmnile12g000gg8cvbt83fddh',
    'cmnile12g000gg8cvbt83fddh','cmnile12g000gg8cvbt83fddh','cmnile12g000gg8cvbt83fddh',
    'cmnile13m000hg8cvdqssqalv','cmnile13m000hg8cvdqssqalv','cmnile13m000hg8cvdqssqalv',
    'cmnile14o000ig8cvmjk5d89x'
  ];

  -- ── 작업 변수 ────────────────────────────────────────────
  v_game_idx  INT;
  v_game_id   TEXT;
  v_servers   TEXT[];
  v_listing_id TEXT;
  v_char_ids  TEXT[];
  v_char_id   TEXT;
  v_i         INT;
  v_n         INT;
  v_created   TIMESTAMPTZ;
  v_server    TEXT;
  v_user      TEXT;
  v_price     INT;
  v_desc      TEXT;
  v_cnt       INT;

BEGIN
  -- ── 4개 게임 × 30개 ────────────────────────────────────
  FOR v_game_idx IN 1..4 LOOP

    CASE v_game_idx
      WHEN 1 THEN v_game_id := GENSHIN_ID;  v_servers := genshin_servers;
      WHEN 2 THEN v_game_id := STARRAIL_ID; v_servers := starrail_servers;
      WHEN 3 THEN v_game_id := ZZZ_ID;      v_servers := zzz_servers;
      WHEN 4 THEN v_game_id := NIKKE_ID;    v_servers := nikke_servers;
    END CASE;

    FOR v_i IN 1..30 LOOP
      v_listing_id := gen_random_uuid()::TEXT;

      -- 30일 내 랜덤 날짜 (고르게 분산)
      v_created := NOW() - (((30.0 - 1) * (v_i - 1) / 29.0 + random() * 2 - 1)
                             * INTERVAL '1 day')::INTERVAL;
      v_created := GREATEST(v_created, NOW() - INTERVAL '30 days');

      -- 가중 서버 선택
      v_server := v_servers[1 + floor(random() * array_length(v_servers, 1))::INT];

      -- 유저 라운드로빈
      v_user := users[1 + ((v_i - 1) % 5)];

      -- 가격 (랜덤, 평균 ~9만)
      v_price := prices[1 + floor(random() * array_length(prices, 1))::INT];

      -- 설명 랜덤
      v_desc := descs[1 + floor(random() * array_length(descs, 1))::INT];

      -- 캐릭터 수 7~15
      v_n := 7 + floor(random() * 9)::INT;

      -- ── Listing INSERT ───────────────────────────────
      INSERT INTO "Listing" (id, "userId", "gameId", "serverId", price, status, description, "createdAt", "updatedAt")
      VALUES (
        v_listing_id,
        v_user,
        v_game_id,
        v_server,
        v_price,
        'sold',
        v_desc,
        v_created,
        v_created + (INTERVAL '1 day' + (random() * INTERVAL '6 days'))
      );

      -- ── 캐릭터 선택 (상위 등급 우선, RANDOM 섞기) ───────
      IF v_game_id = NIKKE_ID THEN
        -- 니케: rarity='SSR', isLimited=true 우선
        SELECT ARRAY(
          SELECT id FROM "Character"
          WHERE "gameId" = v_game_id AND rarity = 'SSR' AND "isActive" = true
          ORDER BY "isLimited" DESC, RANDOM()
          LIMIT v_n
        ) INTO v_char_ids;
      ELSE
        -- 원신/스타레일/젠레스: tier='S'
        SELECT ARRAY(
          SELECT id FROM "Character"
          WHERE "gameId" = v_game_id AND tier = 'S' AND "isActive" = true
          ORDER BY RANDOM()
          LIMIT v_n
        ) INTO v_char_ids;
      END IF;

      -- fallback: S급 캐릭터가 부족하면 전체에서 선택
      SELECT COALESCE(array_length(v_char_ids, 1), 0) INTO v_cnt;
      IF v_cnt < 5 THEN
        SELECT ARRAY(
          SELECT id FROM "Character"
          WHERE "gameId" = v_game_id AND "isActive" = true
          ORDER BY RANDOM()
          LIMIT v_n
        ) INTO v_char_ids;
      END IF;

      -- ── ListingCharacter INSERT ──────────────────────
      IF v_char_ids IS NOT NULL THEN
        FOREACH v_char_id IN ARRAY v_char_ids LOOP
          INSERT INTO "ListingCharacter" ("listingId", "characterId", count)
          VALUES (v_listing_id, v_char_id, 1)
          ON CONFLICT DO NOTHING;
        END LOOP;
      END IF;

    END LOOP; -- 30개 루프
  END LOOP;   -- 4게임 루프

  RAISE NOTICE '✅ 더미 매물 생성 완료 (4게임 × 30개 = 120개)';
END $$;

-- ── 검증 쿼리 ─────────────────────────────────────────────
SELECT
  g.slug,
  COUNT(DISTINCT l.id)         AS listings,
  COUNT(lc."characterId")      AS total_chars,
  ROUND(AVG(l.price))          AS avg_price,
  MIN(l.price)                 AS min_price,
  MAX(l.price)                 AS max_price,
  MIN(l."createdAt")::DATE     AS oldest,
  MAX(l."createdAt")::DATE     AS newest
FROM "Listing" l
JOIN "Game" g ON l."gameId" = g.id
LEFT JOIN "ListingCharacter" lc ON lc."listingId" = l.id
WHERE l.status = 'sold'
  AND l."createdAt" > NOW() - INTERVAL '35 days'
GROUP BY g.slug
ORDER BY g.slug;

-- ── 서버별 분포 ───────────────────────────────────────────
SELECT
  g.slug,
  s."nameKo" AS server,
  COUNT(*)  AS cnt
FROM "Listing" l
JOIN "Game" g ON l."gameId" = g.id
JOIN "Server" s ON l."serverId" = s.id
WHERE l.status = 'sold'
  AND l."createdAt" > NOW() - INTERVAL '35 days'
GROUP BY g.slug, s."nameKo"
ORDER BY g.slug, cnt DESC;

-- ── 사용자별 분포 ─────────────────────────────────────────
SELECT "userId", COUNT(*) AS cnt
FROM "Listing"
WHERE status = 'sold'
  AND "createdAt" > NOW() - INTERVAL '35 days'
GROUP BY "userId"
ORDER BY cnt DESC;

-- ⚠️  검토 후 COMMIT 또는 ROLLBACK 선택:
-- ROLLBACK;   -- 되돌리기 (테스트용)
COMMIT;        -- 확정 적용
