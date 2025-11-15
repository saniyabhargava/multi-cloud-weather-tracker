module.exports = async function (context, req) {
  try {
    const apiKey = process.env.OPENWEATHER_API_KEY;
    const city = (req.query.city || "").trim();
    const country = (req.query.country || "").trim();

    if (!apiKey) { context.res = { status: 500, body: { error: "Missing OPENWEATHER_API_KEY" } }; return; }
    if (!city)   { context.res = { status: 400, body: { error: "city required" } }; return; }

    const q   = encodeURIComponent(country ? `${city},${country}` : city);
    const url = `https://api.openweathermap.org/data/2.5/weather?q=${q}&appid=${apiKey}&units=metric`;

    const r    = await fetch(url);
    const data = await r.json();

    const origin = req.headers.origin || "*";
    context.res = {
      status: r.ok ? 200 : r.status,
      headers: {
        "content-type": "application/json",
        "cache-control": "public, max-age=60",
        "access-control-allow-origin": origin,
        "vary": "Origin"
      },
      body: data
    };
  } catch (e) {
    context.log.error(e);
    const origin = req.headers.origin || "*";
    context.res = {
      status: 500,
      headers: { "content-type": "application/json", "access-control-allow-origin": origin, "vary": "Origin" },
      body: { error: String(e) }
    };
  }
};
