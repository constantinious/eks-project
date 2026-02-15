# Prague Dashboard Demo App

A Flask-based web application that displays:
- **Prague Weather**: Current temperature, conditions, humidity, wind speed
- **CZK/EUR Exchange Rate**: Live currency conversion rates

## Features

- 🌤️ Real-time Prague weather from OpenWeatherMap API
- 💱 Live CZK ↔ EUR exchange rates
- 🎨 Modern, responsive UI with gradient design
- 🔄 Auto-refresh every 5 minutes
- 📱 Mobile-friendly responsive layout
- 🛡️ Fallback to demo data if APIs are unavailable
- ✅ Health check endpoint at `/health`

## Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally
python app.py

# Access at http://localhost:8080
```

## Docker

```bash
# Build image
docker build -t prague-dashboard:latest .

# Run container
docker run -p 8080:8080 prague-dashboard:latest
```

## Environment Variables (Optional)

- `OPENWEATHER_API_KEY`: OpenWeatherMap API key (uses demo data if not set)
- `EXCHANGE_API_KEY`: Exchange rate API key (uses free API if not set)

## Kubernetes Deployment

This app is designed to be deployed on EKS and managed by ArgoCD. See the `kubernetes/manifests/` directory for deployment configurations.

## APIs Used

- **Weather**: OpenWeatherMap API (free tier)
- **Exchange Rates**: exchangerate-api.com (free tier, no key required)

Both APIs have fallback demo data to ensure the app always displays something useful.
