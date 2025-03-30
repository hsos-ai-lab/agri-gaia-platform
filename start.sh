#!/usr/bin/env bash

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

usage() {
  echo "Usage: ${0} [-u <project_base_url>] [-e <exclude_profiles>]"
  echo "Example: ${0} -u agri-gaia.localhost -e monitoring,triton"
}

while getopts u:e:h opt
do
  case "${opt}" in
    u) project_base_url="${OPTARG}";;
    e) exclude_profiles="${OPTARG}";;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Option '-$OPTARG' is not a valid option." >&2
      usage
      exit 2
      ;;
    : )
      echo "Option '-$OPTARG' needs an argument." >&2
      usage
      exit 3
      ;;
  esac
done

if [[ -z "${project_base_url}" ]]; then
  project_base_url="agri-gaia.localhost"
fi

compose_profiles="edge,annotation,semantics,monitoring,edc,triton"

if [[ -n "${exclude_profiles}" ]]; then
  IFS=','
  for exclude_profile in ${exclude_profiles}; do
    compose_profiles="${compose_profiles//"${exclude_profile}"/}"
    compose_profiles="${compose_profiles//,,/,}"
    compose_profiles="${compose_profiles#,}"
    compose_profiles="${compose_profiles%,}"
  done
fi

jupyterhub_images_path="./services/jupyterhub/images"
jupyterhub_version="$(grep "JUPYTERHUB_VERSION=" .env | cut -d "=" -f 2)"

cd "${jupyterhub_images_path}" && ./build-cpu-images.sh "${jupyterhub_version}"
cd - || exit

export COMPOSE_PROFILES="${compose_profiles}"

overrides="-f docker-compose.yml -f docker-compose.override.yml -f docker-compose-overrides/self-signed.yml"
if command -v nvidia-container-toolkit &> /dev/null; then
  overrides="${overrides} -f docker-compose-overrides/backend-gpus.yml"

  jupyterhub_ngc_image_tag="$(grep "JUPYTERHUB_NGC_IMAGE_TAG=" .env | cut -d "=" -f 2)"
  cd "${jupyterhub_images_path}" && ./build-gpu-images.sh "${jupyterhub_version}" "${jupyterhub_ngc_image_tag}"
  cd - || exit
fi

docker compose pull \
  && eval "docker compose ${overrides} up -d --build"
