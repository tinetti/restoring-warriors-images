set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# Show available recipes.
default: help
help:
  @just --list

# Start the local MinIO stack.
compose-up:
  docker compose up -d --build

# Stop the local MinIO stack.
compose-down:
  docker compose down

# Tail logs from the local MinIO stack.
compose-logs:
  docker compose logs -f

# Create the configured bucket and make sample objects public-readable.
init-bucket:
  docker compose --profile tools run --rm mc /scripts/init-bucket.sh

# Upload the deterministic sample object.
upload-sample:
  docker compose --profile tools run --rm mc /scripts/upload-sample-object.sh

# Run the local validation checks.
validate-local:
  bucket="${MINIO_BUCKET:-restoring-warriors-images}"; \
  for attempt in {1..30}; do \
    if curl -fsS http://localhost:9000/minio/health/live >/dev/null; then \
      break; \
    fi; \
    if [ "${attempt}" -eq 30 ]; then \
      exit 1; \
    fi; \
    sleep 1; \
  done; \
  curl -fsS -I http://localhost:9001 >/dev/null; \
  curl -fsS "http://localhost:9000/${bucket}/samples/phase-1-check.txt" >/dev/null
