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

# ---------------------------------------------------------------------------
# Deployment helpers (require GITHUB_TOKEN in keychain via devops-tools)
# ---------------------------------------------------------------------------

INFRA_REPO := "tinetti/devops-tools"

# Deploy to dev: builds the Docker image, then dispatches devops-tools deploy-dev.yml
# with the current commit SHA.  Requires GITHUB_TOKEN.
deploy-dev:
  @if [ -z "$GITHUB_TOKEN" ]; then echo "Error: GITHUB_TOKEN not set. Run: eval \"\$(bash ../devops-tools/scripts/secrets.sh load)\""; exit 1; fi
  @echo "Deploying to dev (commit $(git rev-parse HEAD))..."
  @INFRA_REPO="$INFRA_REPO" GITHUB_TOKEN="$GITHUB_TOKEN" bash ../devops-tools/scripts/trigger-deploy.sh restoring-warriors-images "$(git rev-parse HEAD)" dev

# Deploy to prod: builds the Docker image, then dispatches devops-tools deploy-prod.yml
# with the latest git tag.  Requires GITHUB_TOKEN.
deploy-prod:
  @if [ -z "$GITHUB_TOKEN" ]; then echo "Error: GITHUB_TOKEN not set. Run: eval \"\$(bash ../devops-tools/scripts/secrets.sh load)\""; exit 1; fi
  @TAG=$(git describe --tags --abbrev=0 2>/dev/null || git rev-parse --short HEAD); \
    echo "Deploying to prod (tag $TAG)..."; \
    INFRA_REPO="$INFRA_REPO" GITHUB_TOKEN="$GITHUB_TOKEN" bash ../devops-tools/scripts/trigger-deploy.sh restoring-warriors-images "$TAG" prod
