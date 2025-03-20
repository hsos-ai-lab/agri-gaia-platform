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

retry_interval=5  # in seconds
max_retries=60

echo "Checking if Keycloak is reachable ..."

retries=0
while [ $retries -lt $max_retries ]; do
    curl --fail -s -o /dev/null $MINIO_IDENTITY_OPENID_CONFIG_URL
    if [ $? -eq 0 ]; then
        break
    else
        echo "Retry $retries/$max_retries: Couldn't reach keycloak. Trying again in 5 seconds."
        sleep $retry_interval
        retries=$((retries + 1))
    fi
done

if [ $retries -eq $max_retries ]; then
    echo "Maximum number of retries reached. Keycloak is still not running. Exiting ..."
    exit 1
fi

echo "Keycloak is running. Starting service ..."
eval $@