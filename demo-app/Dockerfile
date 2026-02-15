FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app.py .
COPY templates templates/

# Create non-root user with numeric UID
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER 1000

# Run with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "4", "--timeout", "60", "app:app"]
