# 리세리스트 (resetlist.kr)

모바일 게임 리세계 계정 직거래 플랫폼. 원신, 블루아카이브, 니케, 쿠키런킹덤, 젠레스 존 제로, 세븐나이츠 리버스, 이환, 트릭컬 리바이브 지원.

## 기술 스택
- 바닐라 HTML/CSS/JS (프레임워크 없음)
- Supabase (DB + Auth)
- Cloudflare Pages (배포) — GitHub `sense-K/listup-site` main 브랜치 push 시 자동 배포
- Cloudflare Pages Functions — 동적 OG 태그 주입 (`functions/` 폴더)
- 도메인: resetlist.kr

## 프로젝트 구조
```
listup-site/
├── index.html              # 홈 (게임카드 + 최신 판매계정)
├── js/
│   ├── config.js           # Supabase 클라이언트, 공용 함수 (navbar, footer, gameUI 등)
│   └── listings.js         # 판매계정 카드 렌더링 + loadListings()
├── css/style.css
├── genshin/                # 원신 리세계
├── bluearchive/            # 블루아카이브 리세계
├── nikke/                  # 니케 리세계
├── cookierunkingdom/       # 쿠키런킹덤 리세계
├── zzz/                    # 젠레스 존 제로 리세계
├── sevenknightsre/         # 세븐나이츠 리버스 리세계
├── leehwan/                # 이환 리세계
├── trickcal/               # 트릭컬 리바이브 리세계
├── listing/                # 판매계정 상세 (/listing/?id=xxx)
├── functions/
│   └── listing/index.js    # Cloudflare Pages Function (동적 OG 태그)
├── trade/
│   ├── register.html       # 판매계정 등록 (3단계: 게임→캐릭터→가격)
│   └── bulk.html           # 일괄 등록
├── auth/                   # 로그인/회원가입
├── mypage/                 # 마이페이지
├── user/                   # 판매자 프로필
├── review/                 # 후기 작성
├── admin/                  # 관리자 페이지
├── contact/                # 문의하기 (Formspree)
├── sitemap.xml             # Google Search Console용
└── robots.txt              # 크롤러 설정
```

## 주요 규칙
- `listup` 폴더는 버린 Next.js 프로젝트, 무시할 것
- 수정 후 항상 git push (자동 배포됨)
- git config: user.email=zzabhm@gmail.com, user.name=sense-K
- git 커밋 시 `git config windows.appendAtomically false` 필요 (Windows 이슈)

## 용어 통일
- 사이트명: **리세리스트** (로고/네비바), **리세 리스트** (본문/SEO)
- "매물" → **판매계정**
- "판매글" → **판매계정** (상세 페이지 등)
- "거래소" → **리세계** (게임 페이지 명칭)

## Supabase 테이블 주요 구조
- `Game` — 게임 목록 (slug, nameKo, emoji, imageUrl, artImageUrl)
- `Server` — 서버 (gameId, nameKo, premium)
- `Character` — 캐릭터 (gameId, nameKo, tier, imageUrl)
- `Listing` — 판매계정 (userId, gameId, serverId, price, status, kakaoOpenChatUrl)
- `ListingCharacter` — 판매계정-캐릭터 연결
- `Trade` — 거래 (listingId, buyerId, sellerId, status)
- `Review` — 후기 (listingId, reviewerId, sellerId, rating, content)
- `User` — 사용자 (nickname, tradeCount, avgRating)

## DB 슬러그 주의사항
- 원신: `genshin`
- 블루아카이브: `bluearchive` (DB slug), URL 경로도 `/bluearchive/`
- 니케: `nikke`
- 쿠키런킹덤: `cookie-run` (DB slug) ← URL 경로는 `/cookierunkingdom/`
  - GRADE_ORDER_MAP 키는 반드시 `'cookie-run'` 사용 (register.html, bulk.html)
- 트릭컬 리바이브: `trickcal` (DB slug), URL 경로 `/trickcal/`
  - 티어 없음 (tier = ''), GRADE_ORDER_MAP 키 없음 → 캐릭터 전체 '캐릭터' 그룹으로 표시
  - 캐릭터 104개, 이미지 Supabase storage `characters/trickcal/trickcal_XXX.png`

## 거래 플로우
`active` → (구매신청) → `trading` → (판매자 전달완료) → `seller_confirmed` → (구매자 후기작성 = 수령확인) → `completed` + Listing `sold`

- 후기작성(`/review/`) = 수령확인. 후기 제출 시 Trade→completed, Listing→sold 처리
- RLS로 buyer가 Trade/Listing 업데이트 못 막히는 경우 있음 → listing 상세 페이지 진입 시 auto-recovery (Review 존재 여부로 완료 판단)

## GRADE_ORDER_MAP (register.html, bulk.html 동일하게 유지)
```js
const GRADE_ORDER_MAP = {
  'nikke':       ['SSS','SS','S','A','B','C'],
  'genshin':     ['SS','S','A','B','C','D','E','F'],
  'bluearchive': ['아비도스','게헨나','밀레니엄 사이언스','트리니티','백귀야행','산해경','붉은겨울','발키리','SRT','아리우스','하이랜더','와일드헌트','사쿠가와','토키와다이','기타'],
  'cookie-run':  ['위치','비스트','에인션트 각성','에인션트','레전더리','드래곤','슈퍼에픽','에픽','레어','커먼'],
}
```

## 히어로 캐러셀 (config.js)
- 대각선 3행 무한스크롤: 1행·3행 우→좌, 2행 좌→우
- CSS: `.hero-diagonal-rows` > `.hero-drow` > `.hero-drow-track` > `.hero-dcard`
- 애니메이션: `hero-scroll-right` 48s, `hero-scroll-left` 40s (linear infinite)
- 카드 배경: `artImageUrl` 이미지

## SEO 현황 (2026-04-12 완료)
- 전 페이지 title / description / keywords / canonical / og / twitter card 적용
- JSON-LD: 메인(WebSite+SearchAction), 게임 페이지(CollectionPage+BreadcrumbList)
- Google Search Console 등록 완료, 색인 생성 요청 완료
- sitemap.xml, robots.txt 배포 완료
- 게임별 주요 키워드:
  - 원신: 자백, 콜롬비나, 스커크, 푸리나, 린네아
  - 블루아카이브: 호시노, 와카모, 시로코, 스나코, 아코
  - 니케: 크라운, 세이렌, 라피, 레드후드, 나유타, 목단
  - 쿠키런킹덤: 어둠마녀, 미스틱플라워, 버닝스파이스, 사일런트솔트, 쉐도우밀크, 이터널슈가

## 공유 기능 (listing/index.html + functions/listing/index.js)
- 판매계정 상세 우측 상단에 `🔗 공유하기` 버튼 → 클립보드 복사 + 토스트 방식
- Cloudflare Pages Function이 `/listing/?id=xxx` 요청 시 Supabase에서 데이터 조회 후 OG 태그 동적 주입
- 카카오톡·디스코드 붙여넣기 시: 게임명·서버·가격·캐릭터 목록 미리보기 표시

## 구매 신청 / 거래 중 처리 (listing/index.html)
- 구매 신청 시 Trade 테이블 insert + Listing status → `trading` 업데이트
- Listing 업데이트가 RLS로 막힐 수 있음 → Trade 테이블 직접 조회로 거래 중 여부 판단
- RLS 정책 "buyer can set listing to trading" 이미 적용 완료 ✅
- 판매글 삭제 시: ListingCharacter → Trade → Listing 순으로 삭제 (FK 제약 때문)
- Supabase CASCADE FK 설정하면 더 안정적 (선택사항, 아래 남은 작업 참고)

## 보안 (2026-04-13 완료)
- register.html, bulk.html: onclick 인라인 JSON 제거 → gameStore/charStore 객체로 교체 (XSS 수정) ✅
- RLS 정책 확인 완료 ✅

## 캐릭터 필터 (2026-04-14 완료)
- 기존 텍스트 검색 제거 → 각 게임 페이지 사이드바에 캐릭터 필터 기능으로 교체
- 사이드바에 "캐릭터 선택 →" 버튼 → 모달 열림 (티어별 그룹, 이미지 7열 그리드)
- 모달 내 실시간 텍스트 검색 (nameKo 기준, 결과 없으면 "검색 결과가 없어요")
- 여러 캐릭터 AND 교집합 필터링 + 개수 필터링 — listings.js의 `characterFilter` 파라미터로 처리
- 선택된 캐릭터는 selected bar + 사이드바 태그 목록으로 표시
- 캐릭터 필터 섹션: 보라색 그라디언트 카드 형태로 시각적 강조 (`.char-filter-section`)
- GRADE_ORDER_MAP / GRADE_DOT_COLOR 각 게임 페이지마다 정의

## 캐릭터 다중 선택 + 개수 필터 (2026-04-15 완료)
- ListingCharacter 테이블에 `count` 컬럼 추가 (SQL: `ALTER TABLE "ListingCharacter" ADD COLUMN count integer NOT NULL DEFAULT 1;`)
- 판매 등록 시 같은 캐릭터를 여러 번 클릭하면 ×N 개수로 등록됨
- 게임 페이지 필터에서 캐릭터를 여러 번 클릭 → ×N 이상 보유 계정만 필터링
- `filterChars` 구조: `{ charId: { char, count } }` (배열 → 맵으로 변경)
- `characterFilter` 파라미터 → listings.js에서 클라이언트 사이드 count 필터링
  - PostgREST URL 파라미터에서 `count`는 예약어 → `.gte('count', N)` 안 됨 → 클라이언트에서 필터
- 선택 시 항상 어두운 오버레이+체크 표시, count>1이면 숫자 뱃지 추가 표시

## 더보기·가격포맷팅 (2026-04-13 완료)
- loadListings()에 `append`, `moreBtn`, `characterIds` 파라미터 추가 (listings.js)
- 게임 페이지 더보기 버튼 추가 (9개씩 append 로드)
- 판매 등록 가격 입력 실시간 쉼표 포맷팅 (register.html, bulk.html)

## 마이페이지 (mypage/index.html)
- 탭 기반 UI: 판매 탭 / 구매 탭
- 판매 탭: 판매 중 + 판매 완료 (아코디언)
- 구매 탭: 거래 진행중 + 거래 완료 + 취소된 거래 (있을 때만)
- 섹션 바디 흰색 배경, 구매 탭 빈 화면 푸터 위치 수정

## 현재 상태 (2026-04-15)
- 핵심 기능 + 보안 + UX 개선 완료
- resetlist.kr 도메인 연결 완료
- SEO + Google Search Console 등록 완료 (zzz, sevenknightsre, leehwan, trickcal 포함)
- 거래 전 플로우 (구매신청→전달완료→후기/수령확인→판매완료) 완성
- 마이페이지: 판매완료 글에서 수정·삭제 버튼 제거, seller_confirmed 상태 auto-recovery
- 캐릭터 필터 모달 완성 (실시간 검색 + 티어 그룹핑 + 보라색 사이드바 카드)
- 캐릭터 다중 선택 + 개수 기반 필터링 완성 (×N 표시, N개 이상 보유 계정 필터)
- 트릭컬 리바이브 페이지 + 캐릭터 104개 등록 완료
- 시세 조회 기능 미구현 (2차 개발 예정)

## 남은 작업 목록
### 중요도 높음
- [ ] Cloudflare Web Analytics 연동 (방문자 분석 도구 없음)
- [ ] 신규 게임(zzz, sevenknightsre, leehwan, trickcal) SEO 키워드 보강 (게임 캐릭터 파악 후)
- [ ] trickcal Google Search Console 색인 생성 요청
- [ ] Supabase CASCADE FK 설정 (판매글 삭제 안정성):
  ```sql
  ALTER TABLE "Trade" DROP CONSTRAINT "Trade_listingId_fkey";
  ALTER TABLE "Trade" ADD CONSTRAINT "Trade_listingId_fkey"
    FOREIGN KEY ("listingId") REFERENCES "Listing"(id) ON DELETE CASCADE;
  ALTER TABLE "ListingCharacter" DROP CONSTRAINT "ListingCharacter_listingId_fkey";
  ALTER TABLE "ListingCharacter" ADD CONSTRAINT "ListingCharacter_listingId_fkey"
    FOREIGN KEY ("listingId") REFERENCES "Listing"(id) ON DELETE CASCADE;
  ```

### 중요도 중간
- [ ] 찜하기 기능 (관심 목록)
- [ ] 필터 강화 (가격 범위, 캐릭터 포함 여부)
- [ ] 모바일 반응형 개선 (히어로 캐러셀 모바일 표시, 게임카드 2열)

### 중요도 낮음
- [ ] 시세 조회 기능 (게임-서버-캐릭터별 평균가)
- [ ] 거래 분쟁 처리 메커니즘
