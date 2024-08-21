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

while getopts :v OPT
do
  case "${OPT}" in
    v) REMOVE_VOLUMES="true";;
    \?)
      echo "Option '-${OPTARG}' is not a valid option." >&2
      usage
      exit 2
      ;;
    : )
      echo "Option '-${OPTARG}' needs an argument." >&2
      usage
      exit 3
      ;;
  esac
done

COMPOSE_PROJECT_NAME="$(grep "COMPOSE_PROJECT_NAME=" .env | cut -d "=" -f 2)"

export COMPOSE_PROFILES=edge,annotation,semantics,monitoring,edc,triton

COMPOSE_DOWN_CMD="docker compose down --remove-orphans"

if [[ "${REMOVE_VOLUMES}" == "true" ]]; then
  COMPOSE_DOWN_CMD="${COMPOSE_DOWN_CMD} -v"
fi

docker ps --filter name="^${COMPOSE_PROJECT_NAME}-jupyter-" -q | xargs -I {} docker stop {}
docker ps -a --filter name="^${COMPOSE_PROJECT_NAME}-jupyter-" -q | xargs -I {} docker rm --force {}

eval "${COMPOSE_DOWN_CMD}"

docker ps --filter name="^nuclio-" -q | xargs -I {} docker stop {}
docker ps -a --filter name="^nuclio-" -q | xargs -I {} docker rm --force {}

if [[ "${REMOVE_VOLUMES}" == "true" ]]; then
  docker volume ls --filter name="^nuclio-" -q \
    | xargs -I {} docker volume rm --force {}
fi