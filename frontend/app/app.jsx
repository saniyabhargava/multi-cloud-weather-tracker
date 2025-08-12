import React, { useEffect, useState } from 'react'

const API_KEY = import.meta.env.VITE_OPENWEATHER_API_KEY

export default function App() {
  const [city, setCity] = useState('Dublin')
  const [country, setCountry] = useState('IE')  // default to Ireland
  const [data, setData] = useState(null)
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(false)

  async function fetchWeather(c, cc) {
    if (!API_KEY) {
      setError('Missing VITE_OPENWEATHER_API_KEY')
      return
    }
    setLoading(true); setError(null); setData(null)
    try {
      const q = `${encodeURIComponent(c)}${cc ? ',' + cc : ''}`
      const url = `https://api.openweathermap.org/data/2.5/weather?q=${q}&appid=${API_KEY}&units=metric`
      const res = await fetch(url)
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      setData(await res.json())
    } catch (e) {
      setError(String(e))
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { fetchWeather(city, country) }, [])

  return (
    <div style={{ fontFamily: 'system-ui, sans-serif', margin: '2rem auto', maxWidth: 720 }}>
      <h1>Multi-Cloud Weather Tracker</h1>
      <p>Active/Passive hosting via AWS S3 (primary) and Azure Static Website (secondary) behind Azure Traffic Manager.</p>

      <div style={{ display: 'flex', gap: '0.5rem', margin: '1rem 0' }}>
        <input value={city} onChange={e => setCity(e.target.value)} placeholder="City" style={{ flex: 1, padding: '0.5rem' }}/>
        <select value={country} onChange={e => setCountry(e.target.value)} style={{ padding: '0.5rem' }}>
          <option value="">(Any)</option>
          <option value="IE">IE</option>
          <option value="US">US</option>
          <option value="GB">GB</option>
          <option value="FR">FR</option>
          <option value="DE">DE</option>
          <option value="IN">IN</option>
        </select>
        <button onClick={() => fetchWeather(city, country)} disabled={loading}>
          {loading ? 'Loading...' : 'Search'}
        </button>
      </div>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      {data && (
        <div style={{ padding: '1rem', border: '1px solid #ddd', borderRadius: 8 }}>
          <h2>{data.name}, {data.sys?.country}</h2>
          <p style={{ fontSize: 32, margin: 0 }}>{Math.round(data.main?.temp)}°C</p>
          <p style={{ marginTop: '0.5rem' }}>{data.weather?.[0]?.main} — {data.weather?.[0]?.description}</p>
          <p>Humidity: {data.main?.humidity}% • Wind: {data.wind?.speed} m/s</p>
          <small>Source: OpenWeatherMap</small>
        </div>
      )}
    </div>
  )
}
