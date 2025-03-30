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

docker compose down -v

compose_project_name="$(grep "^COMPOSE_PROJECT_NAME=" .env | cut -f 2 -d '=')"

containers=$(docker container ls -a --filter name="${compose_project_name}" -q)
[[ -n "${containers}" ]] && docker container rm "${containers}"

volumes=$(docker volume ls --filter name="${compose_project_name}" -q)
[[ -n "${volumes}" ]] && docker volume rm "${volumes}"

project_base_url="$(grep "^PROJECT_BASE_URL=" .env | cut -f 2 -d '=')"
if [[ -n "${project_base_url}" ]]; then
  docker container ls -a --format "{{.ID}} {{.Image}}" \
    | grep "registry.${project_base_url}" \
    | awk '{print $1}' \
    | xargs -I {} sh -c 'docker stop {} && docker rm {}'

  docker image ls -a --format "{{.ID}} {{.Repository}}" \
    | grep "registry.${project_base_url}" \
    | awk '{print $1}' \
    | xargs -I {} docker rmi -f {}
fi
