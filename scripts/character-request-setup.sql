-- ============================================================
-- character-request-setup.sql
-- 캐릭터 추가 요청 테이블 + RLS 정책
-- ⚠️  Supabase SQL Editor에서 직접 실행하세요.
-- ※ 이 DB는 Prisma 컨벤션으로 모든 ID가 TEXT 타입
-- ============================================================

-- 1. 테이블 생성
CREATE TABLE IF NOT EXISTS "CharacterRequest" (
  id              TEXT        PRIMARY KEY DEFAULT gen_random_uuid()::text,
  "userId"        TEXT        NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
  "gameId"        TEXT        NOT NULL REFERENCES "Game"(id) ON DELETE CASCADE,
  "characterName" TEXT        NOT NULL,
  status          TEXT        NOT NULL DEFAULT 'pending'
                              CHECK (status IN ('pending', 'done', 'rejected')),
  "createdAt"     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. 인덱스
-- 어드민 페이지: 게임별 pending 조회
CREATE INDEX IF NOT EXISTS idx_char_req_game_status
  ON "CharacterRequest"("gameId", status);

-- 본인 요청 이력: 최신순 조회
CREATE INDEX IF NOT EXISTS idx_char_req_user_created
  ON "CharacterRequest"("userId", "createdAt" DESC);

-- 3. RLS 활성화
ALTER TABLE "CharacterRequest" ENABLE ROW LEVEL SECURITY;

-- 4. RLS 정책

-- INSERT: 로그인한 사용자가 본인 userId로만 가능
DROP POLICY IF EXISTS "user_insert_own_char_request" ON "CharacterRequest";
CREATE POLICY "user_insert_own_char_request" ON "CharacterRequest"
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid()::text = "userId");

-- SELECT: 어드민만 가능
DROP POLICY IF EXISTS "admin_select_char_request" ON "CharacterRequest";
CREATE POLICY "admin_select_char_request" ON "CharacterRequest"
  FOR SELECT TO authenticated
  USING (auth.jwt() ->> 'email' = 'zzabhm@gmail.com');

-- UPDATE: 어드민만 가능 (status 변경)
DROP POLICY IF EXISTS "admin_update_char_request" ON "CharacterRequest";
CREATE POLICY "admin_update_char_request" ON "CharacterRequest"
  FOR UPDATE TO authenticated
  USING (auth.jwt() ->> 'email' = 'zzabhm@gmail.com');

-- DELETE: 어드민만 가능
DROP POLICY IF EXISTS "admin_delete_char_request" ON "CharacterRequest";
CREATE POLICY "admin_delete_char_request" ON "CharacterRequest"
  FOR DELETE TO authenticated
  USING (auth.jwt() ->> 'email' = 'zzabhm@gmail.com');

-- 5. 검증
SELECT table_name, row_security
FROM information_schema.tables
WHERE table_name = 'CharacterRequest';
