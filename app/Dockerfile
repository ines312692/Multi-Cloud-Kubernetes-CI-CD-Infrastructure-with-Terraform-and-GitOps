# syntax=docker/dockerfile:1
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=8080

# User non-root
RUN useradd -u 10001 -m appuser

WORKDIR /app

# Dépendances système minimales
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Installer requirements en amont pour profiter du cache
COPY app/requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copie du code
COPY app/ /app/

# Droits
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

# Healthcheck côté conteneur
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -fsS http://127.0.0.1:${PORT}/health || exit 1

# Lancer en prod avec gunicorn
CMD ["gunicorn", "-w", "2", "-k", "gthread", "-b", "0.0.0.0:8080", "app:app"]