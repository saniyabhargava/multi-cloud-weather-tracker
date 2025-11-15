import React, { useEffect, useState } from 'react'

const API_KEY = import.meta.env.VITE_OPENWEATHER_API_KEY
const PROXY   = (import.meta.env.VITE_WEATHER_PROXY || '').trim() // empty if not set

export default function App() {
  const [city, setCity] = useState('Dublin')
  const [country, setCountry] = useState('IE')
  const [data, setData] = useState(null)
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(false)

  async function fetchWeather(c, cc) {
    setLoading(true); setError(null); setData(null)
    try {
      let url
      if (PROXY) {
        // use your Azure Function proxy – no API key in the browser
        const qCity = encodeURIComponent(c)
        url = `${PROXY}?city=${qCity}${cc ? `&country=${cc}` : ''}`
      } else {
        // fall back to calling OpenWeather directly
        if (!API_KEY) { setError('Missing VITE_OPENWEATHER_API_KEY'); return }
        const q = encodeURIComponent(cc ? `${c},${cc}` : c)
        url = `https://api.openweathermap.org/data/2.5/weather?q=${q}&appid=${API_KEY}&units=metric`
      }

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

  /* …the rest of your component stays the same… */
}
