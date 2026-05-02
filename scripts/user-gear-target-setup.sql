-- ============================================================
-- user-gear-target-setup.sql
-- 에픽세븐 강화 어시스트 — 사용자별 목표 점수 저장 테이블
-- ⚠️  Supabase SQL Editor에서 직접 실행하세요.
-- ============================================================

-- 테이블 생성
CREATE TABLE IF NOT EXISTS "UserGearTarget" (
  user_id      TEXT        NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
  preset       TEXT        NOT NULL,   -- 'main' (주력) | 'sub' (서브)
  stage        INTEGER     NOT NULL,   -- 3 | 6 | 9 | 12
  target_score NUMERIC     NOT NULL,
  updated_at   TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, preset, stage)
);

-- RLS 활성화
ALTER TABLE "UserGearTarget" ENABLE ROW LEVEL SECURITY;

-- 본인 데이터 조회 정책
CREATE POLICY "user_select_own_gear_target" ON "UserGearTarget"
  FOR SELECT TO authenticated
  USING (user_id = auth.uid()::text);

-- 본인 데이터 INSERT 정책
CREATE POLICY "user_insert_own_gear_target" ON "UserGearTarget"
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid()::text);

-- 본인 데이터 UPDATE 정책
CREATE POLICY "user_update_own_gear_target" ON "UserGearTarget"
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()::text);

-- 검증 쿼리
SELECT table_name, row_security
FROM information_schema.tables
WHERE table_name = 'UserGearTarget';
