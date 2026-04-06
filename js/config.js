// ===== Supabase 설정 =====
const SUPABASE_URL = 'https://ltcibadxwkupwjikqzik.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx0Y2liYWR4d2t1cHdqaWtxemlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxMTQ5OTEsImV4cCI6MjA5MDY5MDk5MX0.KYrP2xopjSxBOee2KcS8tM89misAkyzfBvx0828t4No'

const { createClient } = supabase
const db = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// ===== 게임 목록 =====
const GAMES = [
  { slug: 'genshin',          nameKo: '원신',        emoji: '🌙', artClass: 'genshin',       path: '/genshin/' },
  { slug: 'bluearchive',      nameKo: '블루아카이브', emoji: '📘', artClass: 'bluearchive',   path: '/bluearchive/' },
  { slug: 'nikke',            nameKo: '니케',         emoji: '⚡', artClass: 'nikke',         path: '/nikke/' },
  { slug: 'cookierunkingdom', nameKo: '쿠키런킹덤',  emoji: '🍪', artClass: 'cookierunkingdom', path: '/cookierunkingdom/' },
]

// ===== 공용 유틸 =====
function formatPrice(price) {
  if (price >= 10000) return (price / 10000).toFixed(1).replace('.0', '') + '만원'
  return price.toLocaleString() + '원'
}

function timeAgo(dateStr) {
  const diff = Date.now() - new Date(dateStr).getTime()
  const m = Math.floor(diff / 60000)
  if (m < 1) return '방금 전'
  if (m < 60) return m + '분 전'
  const h = Math.floor(m / 60)
  if (h < 24) return h + '시간 전'
  return Math.floor(h / 24) + '일 전'
}

function renderNavbar(activePage = '') {
  return `
    <nav class="navbar">
      <div class="navbar-inner">
        <a href="/" class="navbar-logo">리스트업</a>
        <div class="navbar-menu">
          <a href="/" class="${activePage === 'home' ? '' : 'muted'}">거래소</a>
          <a href="#" class="muted">공지사항</a>
          <a href="#" class="muted">이용안내</a>
        </div>
        <div class="navbar-actions">
          <a href="#" class="login-btn">로그인</a>
          <a href="/trade/register.html" class="navbar-sell-btn">판매하기 ↗</a>
        </div>
      </div>
    </nav>
  `
}

function renderSidebarGames(activeSlug) {
  return `
    <div class="sidebar-section">
      <div class="sidebar-label">게임</div>
      <div class="sidebar-game-list">
        <a href="/" class="sidebar-game-item ${!activeSlug ? 'active' : ''}">전체</a>
        ${GAMES.map(g => `
          <a href="${g.path}" class="sidebar-game-item ${g.slug === activeSlug ? 'active' : ''}">
            ${g.emoji} ${g.nameKo}
          </a>
        `).join('')}
      </div>
    </div>
  `
}
