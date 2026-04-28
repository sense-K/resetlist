export async function onRequest({ request, params }) {
  // OPTIONS preflight
  if (request.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders() })
  }

  const path = Array.isArray(params.path)
    ? params.path.join('/')
    : (params.path || '')
  const url = new URL(request.url)
  const queryString = url.search

  // 화이트리스트: cgfw 경로만 허용
  if (!path.startsWith('cgfw/')) {
    return new Response(JSON.stringify({ error: 'forbidden' }), {
      status: 403,
      headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
    })
  }

  try {
    const targetUrl = `https://api.dotgg.gg/${path}${queryString}`
    const res = await fetch(targetUrl, {
      headers: { 'User-Agent': 'resetlist.kr/1.0' },
    })

    if (!res.ok) {
      return new Response(
        JSON.stringify({ error: 'upstream', status: res.status, url: targetUrl }),
        { status: res.status, headers: { ...corsHeaders(), 'Content-Type': 'application/json' } }
      )
    }

    return new Response(await res.text(), {
      status: 200,
      headers: {
        ...corsHeaders(),
        'Content-Type': 'application/json',
        'Cache-Control': 'public, max-age=3600',
      },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), {
      status: 500,
      headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
    })
  }
}

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  }
}
