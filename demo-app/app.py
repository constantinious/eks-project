from flask import Flask, render_template, jsonify
import requests
from datetime import datetime
import os

app = Flask(__name__)

# API keys from environment variables (with fallback for local dev)
OPENWEATHER_API_KEY = os.environ.get('OPENWEATHER_API_KEY', 'demo')
EXCHANGE_API_KEY = os.environ.get('EXCHANGE_API_KEY', 'demo')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/weather')
def get_weather():
    """Get Prague weather from OpenWeatherMap"""
    try:
        # Using free OpenWeatherMap API
        url = f"https://api.openweathermap.org/data/2.5/weather?q=Prague,CZ&appid={OPENWEATHER_API_KEY}&units=metric"
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            return jsonify({
                'success': True,
                'temperature': round(data['main']['temp'], 1),
                'feels_like': round(data['main']['feels_like'], 1),
                'description': data['weather'][0]['description'].capitalize(),
                'humidity': data['main']['humidity'],
                'wind_speed': round(data['wind']['speed'], 1),
                'icon': data['weather'][0]['icon']
            })
        else:
            # Fallback to mock data if API fails
            return jsonify({
                'success': True,
                'temperature': 8.5,
                'feels_like': 6.2,
                'description': 'Partly cloudy',
                'humidity': 75,
                'wind_speed': 3.2,
                'icon': '02d',
                'mock': True
            })
    except Exception as e:
        app.logger.error(f"Weather API error: {e}")
        # Return mock data on error
        return jsonify({
            'success': True,
            'temperature': 8.5,
            'feels_like': 6.2,
            'description': 'Partly cloudy',
            'humidity': 75,
            'wind_speed': 3.2,
            'icon': '02d',
            'mock': True
        })

@app.route('/api/exchange')
def get_exchange():
    """Get CZK to EUR exchange rate"""
    try:
        # Using exchangerate-api.com free tier
        url = "https://api.exchangerate-api.com/v4/latest/EUR"
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            czk_rate = data['rates']['CZK']
            eur_to_czk = round(czk_rate, 2)
            czk_to_eur = round(1 / czk_rate, 4)
            
            return jsonify({
                'success': True,
                'eur_to_czk': eur_to_czk,
                'czk_to_eur': czk_to_eur,
                'last_updated': data['date']
            })
        else:
            # Fallback to approximate rate
            return jsonify({
                'success': True,
                'eur_to_czk': 25.10,
                'czk_to_eur': 0.0398,
                'last_updated': datetime.now().strftime('%Y-%m-%d'),
                'mock': True
            })
    except Exception as e:
        app.logger.error(f"Exchange API error: {e}")
        # Return mock data on error
        return jsonify({
            'success': True,
            'eur_to_czk': 25.10,
            'czk_to_eur': 0.0398,
            'last_updated': datetime.now().strftime('%Y-%m-%d'),
            'mock': True
        })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
