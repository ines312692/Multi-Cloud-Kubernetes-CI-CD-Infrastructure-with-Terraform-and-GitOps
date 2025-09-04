from flask import Flask, jsonify
import os
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)

# Expose /metrics automatiquement
metrics = PrometheusMetrics(app, group_by='endpoint')

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

@app.route('/')
def hello():
    return jsonify({
        "message": "Welcome to Multi-Cloud Demo App",
        "environment": os.getenv("ENVIRONMENT", "development")
    })

if __name__ == '__main__':
    # Mode dev local uniquement
    app.run(host='0.0.0.0', port=8080, debug=True)