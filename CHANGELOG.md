# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-06-15

### Changed

- **Keycloak 24.0.4 → 26.6.0**
  - Base image bumped in `services/keycloak/Dockerfile` (`24.0.4` → `26.5.6` → `26.6.0`). (593e550, d0d6404)
  - Build stage upgraded to Maven `3.9.8-eclipse-temurin-21` (Java 11 → 21). Added `--metrics-enabled=true --cache=local` to the Keycloak build flags. (593e550)
  - `services/keycloak/registration-hook-spi/pom.xml`: Keycloak `14.0.0` → `26.6.0`, Jackson `2.12.1` → `2.18.6`, Maven compiler plugin `3.8.0` → `3.13.0`, source/target Java 11 → 21, JUnit `4.13` → `4.13.1`. (bebc4bf, d0d6404, cf9949c)
  - `keycloak-metrics-spi.jar` upgraded `5.0.0` → `7.0.0`. (1e06314, 593e550)
  - `services/keycloak/startup.sh`: switched from `--proxy edge` to `--proxy-headers xforwarded --http-enabled true`; internal healthcheck port `8080` → `9000`; env var renamed `KEYCLOAK_ADMIN_PASSWORD` → `KC_BOOTSTRAP_ADMIN_PASSWORD`; replaced `tail -f /dev/null` with `wait $KC_PID` so a Keycloak crash actually exits the container and Docker restarts it. (bebc4bf)
  - `services/keycloak/startup.sh` hardened further: waits on the **master realm OIDC endpoint** (`/realms/master/.well-known/openid-configuration` on port 8080) instead of the generic `:9000/health` port — this proves both the API and the bootstrap admin row are ready; added a **kcadm login retry loop** (12 × 5s) because the bootstrap admin row can land slightly after OIDC responds; uses `$KC_BOOTSTRAP_ADMIN_USERNAME` instead of the now-removed `$KEYCLOAK_ADMIN`; service-account user creation made idempotent (duplicate-user errors swallowed); explicit error-exit guards and clearer log messages added. (43909dc)
- **JupyterHub 4.0 → 5.4**
  - `.env`: `JUPYTERHUB_VERSION` `4.0.0` → `5.4.6`. (e61de4e)
  - Image build args in `services/jupyterhub/images/Dockerfile.jupyter|pytorch|tf2`: `4.0.2` → `5.4.5`; base registry switched from `jupyter/*` to `quay.io/jupyter/*`. (09930fe)
  - `services/jupyterhub/requirements.txt`: `dockerspawner` `~=12.1.0` → `>=13.0.0`; `oauthenticator` `~=16.3.0` → `>=17.4.0`. (09930fe)
  - Authenticator/spawner config updated for the new API: `username_key` → `username_claim`, deprecated JWT signature check removed, user paths pinned to `/home/jovyan`. (09930fe)
- **Triton inference server**: `nvcr.io/nvidia/tritonserver:23.12-py3` → `24.09-py3` in `docker-compose.yml`. (f446142)
- **Compose health & startup ordering tweaks** (`docker-compose.yml`):
  - MinIO healthcheck endpoint: `/minio/health/live` → `/minio/health/ready` (live just confirms the process is up; ready waits for the object store + listener — what Triton's S3 init actually needs).
  - Keycloak env var renamed `KEYCLOAK_ADMIN` → `KC_BOOTSTRAP_ADMIN_USERNAME` (matches the existing `KC_BOOTSTRAP_ADMIN_PASSWORD` pattern in 26.x); healthcheck tuning `retries: 100 / start_period: 15s` → `retries: 10 / start_period: 30s` (fail-fast).
  - Triton: `AWS_DEFAULT_REGION` `eu-central-1` → `us-east-1` (the embedded AWS SDK requires a region for non-AWS S3 endpoints; `us-east-1` is the MinIO convention); removed `--exit-on-error=false` so a startup failure exits the container and Docker can restart it.
  - Frontend service now declares `depends_on: backend` so the UI cannot render before the API is reachable. (acb8deb)
- **`backend` & `frontend` `depends_on` reworked to long-form with explicit health conditions** (`docker-compose.yml`):
  - `backend`: requires `keycloak: service_healthy`, `postgres_backend: service_started`, `build_container: service_started`, `registry: service_started`, **and `fuseki: service_healthy`** (new).
  - `frontend`: requires `keycloak: service_healthy`, `minio: service_healthy`, `backend: service_healthy`, `cvat_server: service_started`.
  - Added a **Fuseki healthcheck** (`wget --spider http://localhost:3030/$$/ping`) so the backend doesn't start before Fuseki is responsive.
  - `KC_HOSTNAME` restored to the full `https://keycloak.${PROJECT_BASE_URL}` URL — Keycloak 26 builds frontend URLs from this value; the scheme must be included or internal callers (e.g. MinIO fetching the OIDC discovery doc) see `http://keycloak:8080` in `authorization_endpoint`. (41fc7f1)
- **Nuclio 1.8.18 → 1.16.4**:
  - `.env`: `NUCLIO_VERSION` `1.8.18` → `1.16.4`. (cf0b84a)
  - `docker-compose.yml`: added a `nuclio-templates-init` busybox sidecar that writes a 22-byte empty `/tmp/templates.zip` stub at startup. Nuclio 1.16's dashboard fetches default function templates from this path and crash-loops if the file is missing; the platform's `/tmp:/tmp` bind mount shadows any zip baked into the image, so a host-side stub is required. The `nuclio` service now declares `depends_on: nuclio-templates-init: condition: service_completed_successfully`. (cf0b84a)
  - Added `services/nuclio/platform.yaml` (logger config with stdout sinks for `system` and `functions` at debug level) and mounted it at `/etc/nuclio/config/platform/platform.yaml`. Nuclio 1.16 mandates a logger block in platform config; without it the dashboard exits at startup with "Must configure at least one logger." (cf0b84a)
- **Docker installer pin**: `.env` `DOCKER_VERSION` `20.10.9` → `29.4.1`. (d67b940)
- **JupyterHub MinIO client**: `WebIdentityProvider(...)` call in `services/jupyterhub/images/platformtools/lib/platformtools/storage.py` updated to use the named parameters (`jwt_provider_func=...`, `sts_endpoint=...`) required by newer `minio` SDK versions. (cd1bc8d)
- **Submodule pointers**: `services/frontend` and `services/backend` bumped to the new Vite / Python-3.12 heads (see the per-submodule `CHANGELOG.md`).
- **EDC service renamed `edc_provider` → `edc`** to shorten subdomain names so the issued wildcard cert stays within Let's Encrypt's CN-length limits.
  - `docker-compose.yml`: service block, `PROVIDER_DATA_ENDPOINT` (`http://edc_provider:8182` → `http://edc:8182`), and all Traefik router/service names renamed (`edc-provider.*` → `edc.*`, `edc-provider-web.*` → `edc-web.*`, `edc-provider-ids.*` → `edc-ids.*`).
  - `docker-compose-overrides/http-acme-eab.yml`, `lets-encrypt-dns.yml`, `lets-encrypt-http.yml`: cert-resolver labels updated to the new router names.
  - `services/edc/Dockerfile` and `README.md`'s example `/etc/hosts` entry updated to match. (4acbf25)
- **Traefik default cert paths reverted** in `services/traefik/dynamic.yaml`: `/certs/agri-gaia.dev.crt` + `.key` → `/certs/agri-gaia.localhost.crt` + `.key`. The deployment's `customize-project-base-url.sh` rewrites these to the actual base URL at deploy time; keeping the source as the `.localhost` variant avoids a mismatch when running the compose stack directly without `deploy.sh`. (6dd6fe0)
