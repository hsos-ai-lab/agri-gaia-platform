# SPDX-FileCopyrightText: 2024 Osnabrück University of Applied Sciences
# SPDX-FileContributor: Andreas Schliebitz
# SPDX-FileContributor: Henri Graf
# SPDX-FileContributor: Jonas Tüpker
# SPDX-FileContributor: Lukas Hesse
# SPDX-FileContributor: Maik Fruhner
# SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
# SPDX-FileContributor: Tobias Wamhof
#
# SPDX-License-Identifier: MIT

ARG MINIO_IMAGE_TAG="RELEASE.2023-08-16T20-17-30Z"

# MinIO archived the open-source MinIO Server project and stopped
# distributing prebuilt binaries/images for it anywhere (Docker Hub, Quay,
# and even their own dl.min.io download server all return "gone"/"requires
# authentication" as of September 2026). Build the pinned release directly
# from the still-public (archived, not deleted) source instead of depending
# on a third party's rebuild of it.
FROM golang:1.19-bookworm AS builder

ARG MINIO_IMAGE_TAG

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --branch "${MINIO_IMAGE_TAG}" --depth 1 https://github.com/minio/minio.git /src
WORKDIR /src

# Mirrors the official `make build` target (see Makefile/Dockerfile.release
# at this tag): a statically linked binary with the same version ldflags,
# derived from the checked-out tag's own commit metadata.
RUN CGO_ENABLED=0 go build -tags kqueue -trimpath \
    --ldflags "$(MINIO_RELEASE=RELEASE go run buildscripts/gen-ldflags.go)" \
    -o /src/minio .

FROM debian:bookworm-slim

# curl/ca-certificates: used by wait-for-keycloak.sh.
# passwd/util-linux: used by docker-entrypoint.sh's optional user-switching.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates passwd util-linux \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY --from=builder /src/minio /usr/bin/minio
RUN chmod +x /usr/bin/docker-entrypoint.sh /usr/bin/minio

COPY wait-for-keycloak.sh .
ENTRYPOINT [ "./wait-for-keycloak.sh", "/usr/bin/docker-entrypoint.sh" ]
