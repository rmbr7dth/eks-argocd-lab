# ── Stage 1: builder ──────────────────────────────────────────────
# Install dependencies in a separate stage so they don't bloat the
# final image. Only the installed packages get copied across.
FROM python:3.12-slim AS builder

WORKDIR /app

# Copy requirements first — Docker caches this layer.
# If requirements.txt hasn't changed, pip install is skipped on rebuild.
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ── Stage 2: runtime ──────────────────────────────────────────────
# Fresh minimal image — no pip, no build tools, no cache.
FROM python:3.12-slim

WORKDIR /app

# Copy installed packages from builder stage only
COPY --from=builder /install /usr/local

# Copy the app source code
COPY . .

# Run as non-root user (UID 1000)
# Security: if the app is compromised, attacker has no root access
USER 1000

EXPOSE 8080

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]

