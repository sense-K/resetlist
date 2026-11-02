-- 자동 완료 함수 1회 즉시 실행 (cron 은 매시 20분; 7일 지난 거래 3건이 대상)
SELECT auto_complete_stale_trades() AS "자동 완료 건수";

\echo '--- 자동 완료된 거래/글 ---'
SELECT t.id AS trade_id, g.slug AS "게임", t.status AS "거래", l.status AS "글",
       to_char(t."autoCompletedAt" AT TIME ZONE 'Asia/Seoul', 'MM-DD HH24:MI') AS "거래 autoCompletedAt",
       to_char(l."autoCompletedAt" AT TIME ZONE 'Asia/Seoul', 'MM-DD HH24:MI') AS "글 autoCompletedAt",
       u.username AS "판매자"
FROM "Trade" t JOIN "Listing" l ON l.id = t."listingId"
JOIN "Game" g ON g.id = l."gameId" JOIN "User" u ON u.id = l."userId"
WHERE t."autoCompletedAt" IS NOT NULL ORDER BY t."autoCompletedAt" DESC;

\echo '--- 남은 거래중 (7일 미만이어야 함) ---'
SELECT g.slug AS "게임", (now() - t."createdAt")::interval(0) AS "경과"
FROM "Trade" t JOIN "Listing" l ON l.id = t."listingId" JOIN "Game" g ON g.id = l."gameId"
WHERE t.status IN ('active','seller_confirmed') ORDER BY t."createdAt";
