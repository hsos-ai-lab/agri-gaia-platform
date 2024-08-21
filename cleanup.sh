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

docker compose down -v

# we manually delete every container and volume matching the project name, because we create additional volumes on runtime for each user
COMPOSE_PROJECT_NAME=$(grep "^COMPOSE_PROJECT_NAME=" .env | cut -f 2 -d '=')

CONTAINERS=$(docker container ls -a --filter name="${COMPOSE_PROJECT_NAME}" -q)

if [ -n "${CONTAINERS}" ]; then
    docker container rm "${CONTAINERS}"
else
    echo "No Containers to remove!"
fi

VOLUMES=$(docker volume ls --filter name="${COMPOSE_PROJECT_NAME}" -q)

if [ -n "${VOLUMES}" ]; then
    docker volume rm "${VOLUMES}"
else
    echo "No Volumes to remove!"
fi

PROJECT_BASE_URL=$(grep "^PROJECT_BASE_URL=" .env | cut -f 2 -d '=')
if [ -n "${PROJECT_BASE_URL}" ]; then
  docker container ls -a --format "{{.ID}} {{.Image}}" \
    | grep "registry.${PROJECT_BASE_URL}" \
    | awk '{print $1}' \
    | xargs -I {} sh -c 'docker stop {} && docker rm {}'

  docker image ls -a --format "{{.ID}} {{.Repository}}" \
    | grep "registry.${PROJECT_BASE_URL}" \
    | awk '{print $1}' \
    | xargs -I {} docker rmi -f {}
fi
