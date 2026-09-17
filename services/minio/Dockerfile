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

# quay.io, not Docker Hub. MinIO withdrew `minio/minio` from Docker Hub, and it
# now fails for every tag -- including `latest` -- with
#   pull access denied, repository does not exist or may require authorization
# which reads like a credentials problem but is not: there is nothing left to
# authorize against. quay.io is MinIO's own mirror and carries the identical
# RELEASE.* tags, so this is a registry change only, not a version bump.
#
# Overridable so a pinned/private mirror can be substituted without editing this
# file; wired through docker-compose.yml's build args like MINIO_IMAGE_TAG.
ARG MINIO_IMAGE="quay.io/minio/minio"
ARG MINIO_IMAGE_TAG="RELEASE.2024-08-03T04-33-23Z"
FROM ${MINIO_IMAGE}:"${MINIO_IMAGE_TAG}"
COPY wait-for-keycloak.sh .
ENTRYPOINT [ "./wait-for-keycloak.sh", "/usr/bin/docker-entrypoint.sh" ]
