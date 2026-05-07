export async function onRequest({ env, request }) {
  return env.ASSETS.fetch(request)
}
