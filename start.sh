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

jupyterhub_images_path="./services/jupyterhub/images"
jupyterhub_version="$(grep "JUPYTERHUB_VERSION=" .env | cut -d "=" -f 2)"

cd "${jupyterhub_images_path}" && ./build-cpu-images.sh "${jupyterhub_version}"
cd - || exit

export COMPOSE_PROFILES=edge,annotation,semantics,monitoring,edc,triton

overrides="-f docker-compose.yml -f docker-compose.override.yml -f docker-compose-overrides/self-signed.yml"
if command -v nvidia-container-toolkit &> /dev/null; then
  overrides="${overrides} -f docker-compose-overrides/backend-gpus.yml"

  jupyterhub_ngc_image_tag="$(grep "JUPYTERHUB_NGC_IMAGE_TAG=" .env | cut -d "=" -f 2)"
  cd "${jupyterhub_images_path}" && ./build-gpu-images.sh "${jupyterhub_version}" "${jupyterhub_ngc_image_tag}"
  cd - || exit
fi

docker compose pull \
  && eval "docker compose ${overrides} up -d --build"
