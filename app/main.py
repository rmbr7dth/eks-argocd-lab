import os
from fastapi import FastAPI

app = FastAPI()

# Read from environment variables — injected by Helm values.yaml
# Falls back to defaults so the app works locally too
UI_COLOR = os.getenv("UI_COLOR", "#34577c")
UI_MESSAGE = os.getenv("UI_MESSAGE", "Hello from Argo CD")
APP_VERSION = os.getenv("APP_VERSION", "dev")   # CD pipeline injects the git SHA here


@app.get("/")
def root():
    return {
        "message": UI_MESSAGE,
        "color": UI_COLOR,
    }


@app.get("/healthz")
def healthz():
    # Kubernetes liveness probe hits this
    # If this returns non-200, Kubernetes RESTARTS the pod
    return {"status": "ok"}


@app.get("/readyz")
def readyz():
    # Kubernetes readiness probe hits this
    # If this returns non-200, Kubernetes stops sending TRAFFIC to the pod
    # (but does not restart it)
    return {"status": "ready"}


@app.get("/version")
def version():
    # This is the money endpoint for the demo
    # After CD runs, this will show the exact git SHA that was deployed
    return {"version": APP_VERSION}

