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
# SPDX-License-Identifier: MIT

export DOCKER_BUILDKIT=1

docker build -f Dockerfile.pytorch \
    --build-arg JUPYTERHUB_VERSION="${1}" \
    --build-arg NGC_IMAGE_TAG="${2}" \
    -t agri-gaia/jupyterhub-notebook-pytorch:"${2}" .

docker build -f Dockerfile.tf2 \
    --build-arg JUPYTERHUB_VERSION="${1}" \
    --build-arg NGC_IMAGE_TAG="${2}" \
    -t agri-gaia/jupyterhub-notebook-tf2:"${2}" .
