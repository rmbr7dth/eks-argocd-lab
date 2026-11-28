from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_root_returns_200():
    response = client.get("/")
    assert response.status_code == 200


def test_root_has_message():
    response = client.get("/")
    data = response.json()
    assert "message" in data
    assert "color" in data


def test_healthz_returns_ok():
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_readyz_returns_ready():
    response = client.get("/readyz")
    assert response.status_code == 200
    assert response.json() == {"status": "ready"}


def test_version_returns_version():
    response = client.get("/version")
    assert response.status_code == 200
    assert "version" in response.json()

