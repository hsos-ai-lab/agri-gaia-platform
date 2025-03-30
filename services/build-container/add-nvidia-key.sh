#!/usr/bin/env sh

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

CONFIG_FILE=$1
NVIDIA_NGC_API_KEY=$2

if [ -z "$NVIDIA_NGC_API_KEY" ]; then
    exit 0
fi

NVIDIA_NGC_AUTH="$(echo -n '$oauthtoken:'"${NVIDIA_NGC_API_KEY}" | base64 -w 0)"

jq --arg nvidia_ngc_auth "${NVIDIA_NGC_AUTH}" '.auths."nvcr.io".auth = $nvidia_ngc_auth' "$CONFIG_FILE" \
| sponge "$CONFIG_FILE"
