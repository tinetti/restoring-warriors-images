#!/bin/sh
set -eu

alias_name="${MINIO_ALIAS:-local}"
endpoint="${MINIO_ENDPOINT:-http://images:9000}"
bucket="${MINIO_BUCKET:?MINIO_BUCKET is required}"
root_user="${MINIO_ROOT_USER:?MINIO_ROOT_USER is required}"
root_password="${MINIO_ROOT_PASSWORD:?MINIO_ROOT_PASSWORD is required}"
sample_path="/samples/phase-1-check.txt"

if [ ! -f "$sample_path" ]; then
  echo "Sample object missing at $sample_path" >&2
  exit 1
fi

mc alias set "$alias_name" "$endpoint" "$root_user" "$root_password" >/dev/null
mc cp "$sample_path" "$alias_name/$bucket/samples/phase-1-check.txt"
