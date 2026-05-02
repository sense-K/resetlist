-- ListingView 트래킹 시스템 검증
-- Supabase SQL Editor에서 실행하여 설치 여부 확인

-- 1. 테이블 존재 여부
SELECT EXISTS (
  SELECT FROM information_schema.tables
  WHERE table_schema = 'public' AND table_name = 'ListingView'
) AS table_exists;

-- 2. 데이터 누적 현황
SELECT COUNT(*) AS total_views FROM "ListingView";

-- 3. RPC 존재 여부
SELECT proname, pronargs
FROM pg_proc
WHERE proname = 'track_listing_view';

-- 4. 최근 조회 10건 (데이터 있을 경우)
SELECT "listingId", ip_hash, "viewedAt"
FROM "ListingView"
ORDER BY "viewedAt" DESC
LIMIT 10;
