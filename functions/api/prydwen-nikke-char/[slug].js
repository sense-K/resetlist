export async function onRequest({ params }) {
  const slug = params.slug
  if (!slug || !/^[a-z0-9-]+$/.test(slug)) {
    return new Response(JSON.stringify({ error: 'invalid slug' }), {
      status: 400, headers: corsHeaders(),
    })
  }

  try {
    const res = await fetch(
      `https://www.prydwen.gg/page-data/nikke/characters/${slug}/page-data.json`,
      { headers: { 'User-Agent': 'resetlist.kr/1.0' } }
    )
    if (!res.ok) {
      return new Response(JSON.stringify({ error: 'not found', status: res.status }), {
        status: res.status, headers: corsHeaders(),
      })
    }
    return new Response(await res.text(), {
      status: 200,
      headers: {
        ...corsHeaders(),
        'Content-Type': 'application/json',
        'Cache-Control': 'public, max-age=86400',
      },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), {
      status: 500, headers: corsHeaders(),
    })
  }
}

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
  }
}
