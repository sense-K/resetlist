# 리셋리스트 (resetlist.kr)

모바일 게임 리세계 계정 직거래 플랫폼. 원신, 블루아카이브, 니케, 쿠키런킹덤 지원.

## 기술 스택
- 바닐라 HTML/CSS/JS (프레임워크 없음)
- Supabase (DB + Auth)
- Cloudflare Pages (배포) — GitHub `sense-K/listup-site` main 브랜치 push 시 자동 배포
- 도메인: resetlist.kr

## 프로젝트 구조
```
listup-site/
├── index.html          # 홈 (게임카드 + 최신매물)
├── js/
│   ├── config.js       # Supabase 클라이언트, 공용 함수 (navbar, footer, gameUI 등)
│   └── listings.js     # 매물 카드 렌더링 + loadListings()
├── css/style.css
├── genshin/            # 원신 거래소
├── bluearchive/        # 블루아카이브 거래소
├── nikke/              # 니케 거래소
├── cookierunkingdom/   # 쿠키런킹덤 거래소
├── listing/            # 매물 상세 (/listing/?id=xxx)
├── trade/register.html # 판매글 등록
├── auth/               # 로그인/회원가입
├── mypage/             # 마이페이지
├── user/               # 판매자 프로필
├── review/             # 후기 작성
├── admin/              # 관리자 페이지
└── contact/            # 문의하기 (Formspree)
```

## 주요 규칙
- `listup` 폴더는 버린 Next.js 프로젝트, 무시할 것
- 수정 후 항상 git push (자동 배포됨)
- git config: user.email=zzabhm@gmail.com, user.name=sense-K
- git 커밋 시 `git config windows.appendAtomically false` 필요 (Windows 이슈)

## Supabase 테이블 주요 구조
- `Game` — 게임 목록 (slug, nameKo, emoji, imageUrl, artImageUrl)
- `Server` — 서버 (gameId, nameKo, premium)
- `Character` — 캐릭터 (gameId, nameKo, tier, imageUrl)
- `Listing` — 매물 (userId, gameId, serverId, price, status, kakaoOpenChatUrl)
- `ListingCharacter` — 매물-캐릭터 연결
- `Trade` — 거래 (listingId, buyerId, sellerId, status)
- `Review` — 후기 (listingId, reviewerId, sellerId, rating, content)
- `User` — 사용자 (nickname, tradeCount, avgRating)

## 거래 플로우
`active` → (구매신청) → `trading` → (판매자 전달완료) → `seller_confirmed` → (구매자 수령확인) → `sold` → 후기작성

## 현재 상태 (2026-04-10)
- 핵심 기능 전부 구현 완료
- resetlist.kr 도메인 연결 완료
- 시세 조회 기능 미구현 (PRD 4-1 참고, 2차 개발 예정)
