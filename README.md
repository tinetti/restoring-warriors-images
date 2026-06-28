# Restoring Warriors Images

`restoring-warriors-images` owns the image-service application contract: the Docker image definition, local Docker Compose workflow, MinIO console exposure, and the operator commands needed to bootstrap a bucket and upload a validation object.

This repo does not own production runtime Compose, DigitalOcean droplets, Nginx routing, SSL, or DNS. Those runtime concerns stay in the shared deployment repository, following the same split already documented for `restoring-warriors-shop`.

## Local Ownership

This repo owns:

- the pinned MinIO image contract in `Dockerfile`
- the local-only Docker Compose stack in `docker-compose.yml`
- local bucket bootstrap and sample-object upload scripts
- operator documentation for local startup and validation

This repo does not yet own:

- DigitalOcean deployment wiring
- test or production domain routing
- full catalog migration from the shop repo
- full shop cutover to the new object store
- any branded MinIO derivative image

## Environment Variables

Copy `.env.example` to `.env` if you want to override defaults.

```text
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
MINIO_BUCKET=restoring-warriors-images
```

## Local Startup

Start the local stack:

```bash
just compose-up
```

This exposes:

- MinIO API: `http://localhost:9000`
- MinIO console: `http://localhost:9001`

Stop the stack:

```bash
just compose-down
```

Tail logs:

```bash
just compose-logs
```

## Bucket Initialization

Create the configured bucket and make uploaded objects public-readable:

```bash
just init-bucket
```

The bootstrap script is idempotent and safe to rerun.

## Sample Object Upload

Upload the deterministic validation object stored at `samples/phase-1-check.txt`:

```bash
just upload-sample
```

The sample object is uploaded to:

```text
<bucket>/samples/phase-1-check.txt
```

With default settings, the public URL is:

```text
http://localhost:9000/restoring-warriors-images/samples/phase-1-check.txt
```

## Validation

Run the local validation loop:

```bash
just validate-local
```

That checks:

- MinIO API health at `http://localhost:9000/minio/health/live`
- console reachability at `http://localhost:9001`
- public fetch of the sample object

Console login is still a quick human verification step using `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`.

## Deferred To Later Phases

Phase 1 intentionally stops short of:

- DigitalOcean deployment onboarding
- `test-images.restoringwarriors.com` and `images.restoringwarriors.com` routing
- full `/images/catalog/...` compatibility and asset migration
- full shop cutover
- branded MinIO packaging
