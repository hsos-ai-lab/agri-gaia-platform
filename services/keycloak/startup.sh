#!/bin/bash

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

REALM_IMPORT_PATH=/opt/keycloak/data/import/realm-export.json

if [ -f "$REALM_IMPORT_PATH" ]; then
    echo "Realm import file found at $REALM_IMPORT_PATH"
else
    echo "Realm import file not found at $REALM_IMPORT_PATH"
    exit 1
fi

/opt/keycloak/bin/kc.sh import --file "$REALM_IMPORT_PATH" --optimized --override false
/opt/keycloak/bin/kc.sh start --proxy-headers xforwarded --http-enabled true --optimized &
KC_PID=$!

# Wait for the master realm — proves admin REST API + bootstrap admin are ready.
echo "Waiting for Keycloak master realm to be ready..."
until curl -sSf "http://localhost:8080/realms/master/.well-known/openid-configuration" > /dev/null 2>&1; do
    echo "Waiting for Keycloak master realm..."
    sleep 5
done
echo "Keycloak master realm is ready."

# kcadm login with retry (bootstrap admin row may land slightly after OIDC responds).
retries=0
until /opt/keycloak/bin/kcadm.sh config credentials \
        --server http://localhost:8080 --realm master \
        --user "$KC_BOOTSTRAP_ADMIN_USERNAME" \
        --password "$KC_BOOTSTRAP_ADMIN_PASSWORD"; do
    retries=$((retries + 1))
    if [ "$retries" -ge 12 ]; then
        echo "ERROR: kcadm login failed after 12 retries. Check KC_BOOTSTRAP_ADMIN_USERNAME / KC_BOOTSTRAP_ADMIN_PASSWORD."
        wait $KC_PID
        exit 1
    fi
    echo "kcadm login retry $retries/12 ..."
    sleep 5
done

echo "kcadm authenticated. Configuring service account..."

# Create the service-account user (idempotent: ignore duplicate-user errors).
/opt/keycloak/bin/kcadm.sh create users -r "${REALM_NAME}" \
    -s username="$REALM_SERVICE_ACCOUNT_USERNAME" -s enabled=true 2>/dev/null || true

USER_ID=$(/opt/keycloak/bin/kcadm.sh get users -r "${REALM_NAME}" \
    -q username="$REALM_SERVICE_ACCOUNT_USERNAME" --fields id \
    | grep -o '"id" : "[^"]*' | sed 's/"id" : "//')

if [ -z "$USER_ID" ]; then
    echo "ERROR: user '$REALM_SERVICE_ACCOUNT_USERNAME' not found in realm '${REALM_NAME}'."
    wait $KC_PID
    exit 1
fi

/opt/keycloak/bin/kcadm.sh set-password -r "${REALM_NAME}" \
    --userid "$USER_ID" --new-password "$REALM_SERVICE_ACCOUNT_PASSWORD"

echo "Service account '$REALM_SERVICE_ACCOUNT_USERNAME' configured successfully."

wait $KC_PID
