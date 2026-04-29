-- ============================================================
-- leehwan-metadata.sql
-- 이환 캐릭터 element / role / arkType 메타데이터 보강
-- 작성일: 2026-04-29
-- ⚠️  Supabase SQL Editor에서 직접 실행하세요. 자동 실행 금지.
-- 저장 방식: element → Character.element 컬럼, role/arkType → metadata JSONB
-- ============================================================

BEGIN;

-- ============================================================
-- S급 캐릭터 (정보 확인된 것만)
-- ============================================================

-- 나나리 | 주속성 | 버퍼 | 기체
UPDATE "Character"
SET element = '주',
    metadata = jsonb_build_object('role', '버퍼', 'arkType', '기체')
WHERE id = '6887c7ae-d187-4f12-98b4-105a58a97d58';

-- 다포딜 | 암속성 | 메인 딜러 | 액체
UPDATE "Character"
SET element = '암',
    metadata = jsonb_build_object('role', '메인 딜러', 'arkType', '액체')
WHERE id = 'd275fe56-b04a-466c-bdd4-33a0b3595950';

-- 백장 | 주속성 | 메인 딜러 | 결합
UPDATE "Character"
SET element = '주',
    metadata = jsonb_build_object('role', '메인 딜러', 'arkType', '결합')
WHERE id = '9c9ea5d9-0115-415e-bcdd-afb3ea344fe3';

-- 하토르 | 상속성 | 스킬 딜러 | 플라즈마
UPDATE "Character"
SET element = '상',
    metadata = jsonb_build_object('role', '스킬 딜러', 'arkType', '플라즈마')
WHERE id = '9835038b-4f0d-46fb-920a-27edb632c913';

-- 파디아 | 혼속성 | 탱커 | 결합
UPDATE "Character"
SET element = '혼',
    metadata = jsonb_build_object('role', '탱커', 'arkType', '결합')
WHERE id = 'f877be58-4612-483b-9511-8ffe2559c2e6';

-- 호토리 | 빛속성 | 역할/아크 미정
UPDATE "Character"
SET element = '빛'
WHERE id = 'fcaa2ef3-0af0-43d5-ae78-2bd1b682d03d';

-- 라크리모사 | 암속성 | 메인 딜러 | 아크 미정
UPDATE "Character"
SET element = '암',
    metadata = jsonb_build_object('role', '메인 딜러')
WHERE id = '77fa0447-38a0-45bc-b071-9ca50f573d15';

-- 치즈 | 빛속성 | 메인 딜러 | 기체
UPDATE "Character"
SET element = '빛',
    metadata = jsonb_build_object('role', '메인 딜러', 'arkType', '기체')
WHERE id = 'f65ada6f-8240-4d61-8635-92dbf1714b3c';

-- 이능력자 제로 | 주인공 (속성/아크 미정)
UPDATE "Character"
SET metadata = jsonb_build_object('role', '주인공')
WHERE id = '337b47d7-df5f-402f-b1b4-9f8985b5571e';

-- ============================================================
-- A급 캐릭터 (정보 확인된 것만)
-- ============================================================

-- 아들러 | 주속성 | 탱커 | 결합
UPDATE "Character"
SET element = '주',
    metadata = jsonb_build_object('role', '탱커', 'arkType', '결합')
WHERE id = '75ec4fc6-32a5-43d7-a314-a4da8be2fa14';

-- 에드가 | 빛속성 | 힐러 | 액체
UPDATE "Character"
SET element = '빛',
    metadata = jsonb_build_object('role', '힐러', 'arkType', '액체')
WHERE id = '26465b0c-ee05-4e5c-808b-995d3272e48b';

-- 하니엘 | 혼속성 | 버퍼 | 고체
UPDATE "Character"
SET element = '혼',
    metadata = jsonb_build_object('role', '버퍼', 'arkType', '고체')
WHERE id = '448295b2-e32a-4048-b16c-fa56b423a474';

-- 스키아 | 상속성 | 메인 딜러 | 기체
UPDATE "Character"
SET element = '상',
    metadata = jsonb_build_object('role', '메인 딜러', 'arkType', '기체')
WHERE id = 'c12a78cf-69bb-4dab-bec2-de4561311e60';

-- ============================================================
-- 검증 쿼리 (COMMIT 전 결과 확인)
-- ============================================================

SELECT
  "nameKo",
  tier,
  element,
  metadata->>'role'    AS role,
  metadata->>'arkType' AS arkType
FROM "Character"
WHERE "gameId" = 'f2e27ed7-5a4f-4c3c-ab72-82ebff336374'
ORDER BY
  CASE tier WHEN 'S' THEN 1 WHEN 'A' THEN 2 WHEN 'B' THEN 3 ELSE 4 END,
  "nameKo";

-- ============================================================
-- 이상 없으면 COMMIT, 문제 있으면 ROLLBACK으로 교체
-- ============================================================
COMMIT;
-- ROLLBACK;
