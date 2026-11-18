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

# MinIO ended community image distribution: docker.io/minio/minio and
# quay.io/minio/minio refuse anonymous pulls for every tag. pgsty/silo is a
# maintained MinIO fork with the same image layout: its entrypoint turns
# `server ...` into `silo server ...`, and MINIO_* variables, /minio/* routes,
# curl and the CA bundle path are unchanged. Overridable via .env.
ARG MINIO_IMAGE="docker.io/pgsty/silo"
ARG MINIO_IMAGE_TAG="RELEASE.2026-11-12T00-00-00Z"
FROM ${MINIO_IMAGE}:"${MINIO_IMAGE_TAG}"
COPY wait-for-keycloak.sh .
ENTRYPOINT [ "./wait-for-keycloak.sh", "/usr/bin/docker-entrypoint.sh" ]
