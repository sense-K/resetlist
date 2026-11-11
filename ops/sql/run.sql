-- 실행할 SQL을 여기에 작성 후 [sql] 태그로 커밋 ([sql-dry]는 ROLLBACK 검증)
-- 2026-11-11 읽기전용: 자동 동기화가 실제로 캐릭터를 넣고 있는지 확인

-- ① 게임별 최근 90일 신규 캐릭터 수 + 마지막 등록일
select g.slug, c.kind,
       count(*) filter (where c."createdAt" >= now() - interval '30 days') as new_30d,
       count(*) filter (where c."createdAt" >= now() - interval '90 days') as new_90d,
       to_char(max(c."createdAt") at time zone 'Asia/Seoul', 'YYYY-MM-DD') as last_added,
       count(*) as total
from "Character" c join "Game" g on g.id = c."gameId"
group by g.slug, c.kind
order by max(c."createdAt") desc nulls last;

-- ② 최근 90일 실제 등록된 캐릭터 목록 (날짜·게임·이름)
select to_char(c."createdAt" at time zone 'Asia/Seoul', 'MM-DD HH24:MI') as at_kst, g.slug, c.kind, c."nameKo",
       (c."imageUrl" is not null) as has_img
from "Character" c join "Game" g on g.id = c."gameId"
where c."createdAt" >= now() - interval '90 days'
order by c."createdAt" desc
limit 60;

-- ③ ImportLog: 게임별 마지막 실행 / 추가 합계 / 에러 일수 (최근 90일)
select game,
       to_char(max("ranAt") at time zone 'Asia/Seoul', 'MM-DD') as last_run,
       sum(added) as added_90d,
       count(*) filter (where error is not null) as error_days,
       count(*) as runs,
       left(max(error), 60) as sample_error
from "ImportLog"
where "ranAt" >= now() - interval '90 days'
group by game order by game;
