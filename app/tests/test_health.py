# app/tests/test_health.py
def test_health_endpoint():
    from app import app
    client = app.test_client()
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json.get("status") == "healthy"