#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 University of Applied Sciences Osnabrück
# SPDX-FileContributor: Andreas Schliebitz
# SPDX-FileContributor: Henri Graf
# SPDX-FileContributor: Jonas Tüpker
# SPDX-FileContributor: Lukas Hesse
# SPDX-FileContributor: Maik Fruhner
# SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
# SPDX-FileContributor: Tobias Wamhof
#
# SPDX-License-Identifier: AGPL-3.0-or-later

PROJECT_BASE_URL="${1}"
WILDCARD_CERTS_PATH="./config/traefik/certs/self-signed/wildcard"

JUPYTERHUB_IMAGES_PATH="./services/jupyterhub/images"
JUPYTERHUB_VERSION="$(grep "JUPYTERHUB_VERSION=" .env | cut -d "=" -f 2)"

if [[ -z "${PROJECT_BASE_URL}" ]]; then
  PROJECT_BASE_URL="agri-gaia.localhost"
fi

# This won't generate new certs if matching ones are already present.
cd "${WILDCARD_CERTS_PATH}" && ./generate.sh -d "${PROJECT_BASE_URL}"
cd - || exit

cd "${JUPYTERHUB_IMAGES_PATH}" && ./build-cpu-images.sh "${JUPYTERHUB_VERSION}"
cd - || exit

export COMPOSE_PROFILES=edge,annotation,semantics,monitoring,edc,triton

OVERRIDES="-f docker-compose.yml -f docker-compose.override.yml -f docker-compose-overrides/self-signed.yml"
if command -v nvidia-container-toolkit &> /dev/null; then
  OVERRIDES="${OVERRIDES} -f docker-compose-overrides/backend-gpus.yml"

  JUPYTERHUB_NGC_IMAGE_TAG="$(grep "JUPYTERHUB_NGC_IMAGE_TAG=" .env | cut -d "=" -f 2)"
  cd "${JUPYTERHUB_IMAGES_PATH}" && ./build-gpu-images.sh "${JUPYTERHUB_VERSION}" "${JUPYTERHUB_NGC_IMAGE_TAG}"
  cd - || exit
fi

docker compose pull \
  && eval "docker compose ${OVERRIDES} up -d --build"