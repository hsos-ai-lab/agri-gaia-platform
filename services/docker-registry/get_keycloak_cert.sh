#!/bin/sh

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

RETRY_INTERVAL=10  # in seconds
MAX_RETRIES=5

# Function to check if the realm exists
check_realm_exists() {
    response=$(curl -s -o /dev/null -w "%{http_code}" "http://keycloak:8080/realms/${KEYCLOAK_REALM_NAME}")
    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

retry_count=0
while true; do
    if check_realm_exists; then
        echo "Realm ${REALM_NAME} is available."
        break
    else
        retry_count=$((retry_count + 1))
        if [ "$retry_count" -ge "$MAX_RETRIES" ]; then
            echo "Max retries reached. Realm ${REALM_NAME} is not available."
            exit 1
        fi
        echo "Realm ${REALM_NAME} is not available yet. Checking again in ${RETRY_INTERVAL} seconds..."
        sleep ${RETRY_INTERVAL}
    fi
done

if [[ ! -z "${CERT_ENDPOINT}" ]]; then
    #CERT_ENDPOINT=$REGISTRY_AUTH_TOKEN_ISSUER/protocol/docker-v2/auth
    mkdir -p $(dirname $REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE)
    CERT_DATA=$(curl -X GET $CERT_ENDPOINT | jq -r '.keys[] | select(.use=="sig") | .x5c[0]')
    TEMPLATE_PATH=$(dirname $0)/cert.pem.tmpl

    CERT_DATA=$CERT_DATA envsubst < $TEMPLATE_PATH > $REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE
fi

# continue with registry
eval $@
