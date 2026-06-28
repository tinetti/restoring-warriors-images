#!/bin/sh
set -eu

alias_name="${MINIO_ALIAS:-local}"
endpoint="${MINIO_ENDPOINT:-http://images:9000}"
bucket="${MINIO_BUCKET:?MINIO_BUCKET is required}"
root_user="${MINIO_ROOT_USER:?MINIO_ROOT_USER is required}"
root_password="${MINIO_ROOT_PASSWORD:?MINIO_ROOT_PASSWORD is required}"

attempts=0
until mc alias set "$alias_name" "$endpoint" "$root_user" "$root_password" >/dev/null 2>&1; do
  attempts=$((attempts + 1))
  if [ "$attempts" -ge 30 ]; then
    echo "MinIO did not become ready at $endpoint" >&2
    exit 1
  fi
  sleep 1
done

mc mb --ignore-existing "$alias_name/$bucket"
mc anonymous set download "$alias_name/$bucket"
