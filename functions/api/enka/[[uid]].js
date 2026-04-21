export async function onRequest({ request, params }) {
  const uid = (params.uid || []).join('/')
  if (!uid || !/^\d+$/.test(uid)) {
    return new Response(JSON.stringify({ error: 'invalid uid' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    })
  }

  try {
    const res = await fetch(`https://enka.network/api/uid/${uid}`, {
      headers: { 'User-Agent': 'resetlist.kr/1.0' },
    })
    const body = await res.text()
    return new Response(body, {
      status: res.status,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Cache-Control': 'public, max-age=60',
      },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: 'proxy error' }), {
      status: 502,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    })
  }
}