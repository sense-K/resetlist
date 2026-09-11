-- 사이트 운영 상태 전수 조사 (읽기 전용)
-- 목적: Supabase / Resend 유료 유지 가치가 있는지 판단할 실제 숫자 확보
-- 주의: SELECT 만. UPDATE/INSERT/DELETE 없음.

\echo ''
\echo '════════════════════════════════════════════════════════════'
\echo ' ① 한눈에 보는 규모'
\echo '════════════════════════════════════════════════════════════'
SELECT
  (SELECT count(*) FROM auth.users)                                             AS "가입계정",
  (SELECT count(*) FROM "User")                                                 AS "User행",
  (SELECT count(*) FROM "Listing")                                              AS "판매계정",
  (SELECT count(*) FROM "Listing" WHERE status = 'active')                      AS "판매중",
  (SELECT count(*) FROM "Trade")                                                AS "거래",
  (SELECT count(*) FROM "Trade" WHERE status = 'completed')                     AS "거래완료",
  (SELECT count(*) FROM "Review")                                               AS "후기",
  (SELECT count(*) FROM "ListingView")                                          AS "조회기록";

\echo ''
\echo '════════════════════════════════════════════════════════════'
\echo ' ② 회원 — 언제 들어왔고, 지금 살아있나'
\echo '════════════════════════════════════════════════════════════'
\echo '--- 월별 가입 (auth.users 기준) ---'
SELECT to_char(date_trunc('month', created_at AT TIME ZONE 'Asia/Seoul'), 'YYYY-MM') AS "월",
       count(*)                                                                       AS "가입"
FROM auth.users GROUP BY 1 ORDER BY 1;

\echo ''
\echo '--- 최근 로그인 분포 (auth.users.last_sign_in_at) ---'
SELECT
  count(*) FILTER (WHERE last_sign_in_at >= now() - interval '7 days')   AS "최근7일 로그인",
  count(*) FILTER (WHERE last_sign_in_at >= now() - interval '30 days')  AS "최근30일",
  count(*) FILTER (WHERE last_sign_in_at >= now() - interval '90 days')  AS "최근90일",
  count(*) FILTER (WHERE last_sign_in_at IS NULL)                        AS "로그인이력 없음",
  max(last_sign_in_at AT TIME ZONE 'Asia/Seoul')                         AS "마지막 로그인(KST)"
FROM auth.users;

\echo ''
\echo '--- 실제로 뭔가 한 회원 (판매계정 등록 이력 기준) ---'
SELECT count(DISTINCT "userId") AS "판매계정 올려본 회원"
FROM "Listing";

\echo ''
\echo '════════════════════════════════════════════════════════════'
\echo ' ③ 판매계정 — 새 글이 꾸준히 올라오나'
\echo '════════════════════════════════════════════════════════════'
\echo '--- 월별 등록 ---'
SELECT to_char(date_trunc('month', "createdAt" AT TIME ZONE 'Asia/Seoul'), 'YYYY-MM') AS "월",
       count(*)                                                                        AS "등록",
       count(DISTINCT "userId")                                                        AS "등록한 사람"
FROM "Listing" GROUP BY 1 ORDER BY 1;

\echo ''
\echo '--- 최근 12주 주별 등록 ---'
SELECT to_char(date_trunc('week', "createdAt" AT TIME ZONE 'Asia/Seoul'), 'MM-DD')     AS "주 시작",
       count(*)                                                                        AS "등록",
       count(DISTINCT "userId")                                                        AS "등록한 사람"
FROM "Listing"
WHERE "createdAt" >= now() - interval '12 weeks'
GROUP BY 1 ORDER BY 1;

\echo ''
\echo '--- 마지막 등록이 언제인가 / 상태 분포 ---'
SELECT status AS "상태", count(*) AS "건수",
       max("createdAt" AT TIME ZONE 'Asia/Seoul') AS "가장 최근 등록(KST)"
FROM "Listing" GROUP BY 1 ORDER BY 2 DESC;

\echo ''
\echo '--- 판매자별 등록 수 상위 10 ---'
SELECT u.nickname AS "상점", u.username AS "아이디", count(l.id) AS "등록",
       max(l."createdAt" AT TIME ZONE 'Asia/Seoul') AS "마지막 등록"
FROM "Listing" l JOIN "User" u ON u.id = l."userId"
GROUP BY 1,2 ORDER BY 3 DESC LIMIT 10;

\echo ''
\echo '════════════════════════════════════════════════════════════'
\echo ' ④ 거래 — 실제로 사고팔린 적이 있나'
\echo '════════════════════════════════════════════════════════════'
SELECT status AS "거래상태", count(*) AS "건수",
       min("createdAt" AT TIME ZONE 'Asia/Seoul') AS "처음",
       max("createdAt" AT TIME ZONE 'Asia/Seoul') AS "마지막"
FROM "Trade" GROUP BY 1 ORDER BY 2 DESC;

\echo ''
\echo '--- 월별 거래 발생 ---'
SELECT to_char(date_trunc('month', "createdAt" AT TIME ZONE 'Asia/Seoul'), 'YYYY-MM') AS "월",
       count(*)                                              AS "구매신청",
       count(*) FILTER (WHERE status = 'completed')          AS "완료"
FROM "Trade" GROUP BY 1 ORDER BY 1;

\echo ''
\echo '════════════════════════════════════════════════════════════'
\echo ' ⑤ 조회수 — 사람이 오고는 있나'
\echo '════════════════════════════════════════════════════════════'
\echo '   ※ 매물 상세 조회만 기록된다. 도감·거래소 페이지뷰는 DB에 없음(GA4에만 있음)'
SELECT to_char(date_trunc('month', "viewedAt" AT TIME ZONE 'Asia/Seoul'), 'YYYY-MM') AS "월",
       count(*)                                              AS "매물조회",
       count(DISTINCT "listingId")                           AS "조회된 매물수"
FROM "ListingView" GROUP BY 1 ORDER BY 1;

\echo ''
\echo '--- 최근 추이 ---'
SELECT
  count(*) FILTER (WHERE "viewedAt" >= now() - interval '7 days')   AS "최근7일",
  count(*) FILTER (WHERE "viewedAt" >= now() - interval '30 days')  AS "최근30일",
  count(*) FILTER (WHERE "viewedAt" >= now() - interval '90 days')  AS "최근90일",
  max("viewedAt" AT TIME ZONE 'Asia/Seoul')                         AS "마지막 조회(KST)"
FROM "ListingView";

\echo ''
\echo '--- 게임별 최근 30일 조회 상위 10 ---'
SELECT g.slug AS "게임", count(*) AS "최근30일 조회"
FROM "ListingView" v
JOIN "Listing" l ON l.id = v."listingId"
JOIN "Game" g    ON g.id = l."gameId"
WHERE v."viewedAt" >= now() - interval '30 days'
GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

\echo ''
\echo '════════════════════════════════════════════════════════════'
\echo ' ⑥ 데이터 용량 — Supabase 요금제 판단용'
\echo '════════════════════════════════════════════════════════════'
SELECT pg_size_pretty(pg_database_size(current_database())) AS "DB 총 용량";

\echo ''
\echo '--- 테이블별 용량 상위 12 ---'
SELECT c.relname AS "테이블",
       pg_size_pretty(pg_total_relation_size(c.oid)) AS "용량",
       s.n_live_tup AS "행수"
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_stat_user_tables s ON s.relid = c.oid
WHERE n.nspname = 'public' AND c.relkind = 'r'
ORDER BY pg_total_relation_size(c.oid) DESC LIMIT 12;

\echo ''
\echo '════════════════════════════════════════════════════════════'
\echo ' ⑦ 최근 30일 요약 — 판단의 핵심'
\echo '════════════════════════════════════════════════════════════'
SELECT
  (SELECT count(*) FROM auth.users WHERE created_at >= now() - interval '30 days')        AS "신규가입",
  (SELECT count(*) FROM auth.users WHERE last_sign_in_at >= now() - interval '30 days')   AS "로그인한 회원",
  (SELECT count(*) FROM "Listing" WHERE "createdAt" >= now() - interval '30 days')        AS "새 판매계정",
  (SELECT count(*) FROM "Trade" WHERE "createdAt" >= now() - interval '30 days')          AS "구매신청",
  (SELECT count(*) FROM "Trade"
     WHERE status='completed' AND "createdAt" >= now() - interval '30 days')              AS "거래완료",
  (SELECT count(*) FROM "ListingView" WHERE "viewedAt" >= now() - interval '30 days')     AS "매물조회";
