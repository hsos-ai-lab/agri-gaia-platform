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

export DOCKER_BUILDKIT=1

docker build -f Dockerfile.jupyter \
    --build-arg JUPYTERHUB_VERSION="${1}" \
    --build-arg NOTEBOOK_TYPE=datascience \
    -t agri-gaia/datascience-notebook:hub-"${1}" .

docker build -f Dockerfile.jupyter \
    --build-arg JUPYTERHUB_VERSION="${1}" \
    --build-arg NOTEBOOK_TYPE=minimal \
    -t agri-gaia/minimal-notebook:hub-"${1}" .
