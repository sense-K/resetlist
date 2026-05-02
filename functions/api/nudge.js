// 연락 요청 프록시
// 브라우저 → /api/nudge (same-origin, CORS 없음)
// CF Function → Supabase Edge Function (server-to-server, CORS 없음)
// quick-responder가 OPTIONS 처리 안 해서 브라우저 직접 호출 시 CORS 에러 발생

const EDGE_URL = 'https://ltcibadxwkupwjikqzik.supabase.co/functions/v1/quick-responder'

export async function onRequestOptions() {
  return new Response(null, { status: 204, headers: corsHeaders() })
}

export async function onRequestPost(context) {
  try {
    const { tradeId, token } = await context.request.json()

    if (!tradeId || !token) {
      return json({ error: 'missing params' }, 400)
    }

    const upstream = await fetch(EDGE_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify({ action: 'nudge', tradeId }),
    })

    return upstream.ok
      ? json({ ok: true }, 200)
      : json({ error: 'upstream error', status: upstream.status }, 502)
  } catch (e) {
    return json({ error: e.message }, 500)
  }
}

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  }
}

function json(body, status) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
  })
}
