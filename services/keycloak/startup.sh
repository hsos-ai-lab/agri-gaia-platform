#!/bin/bash

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

REALM_IMPORT_PATH=/opt/keycloak/data/import/realm-export.json

# Ensure the import directory exists and contains the realm export file
if [ -f "$REALM_IMPORT_PATH" ]; then
    echo "Realm import file found at $REALM_IMPORT_PATH"
else
    echo "Realm import file not found at $REALM_IMPORT_PATH"
    exit 1
fi

# Starte den Keycloak-Server im Hintergrund
/opt/keycloak/bin/kc.sh import --file $REALM_IMPORT_PATH --optimized --override false
/opt/keycloak/bin/kc.sh start --proxy edge --optimized &

# Warte bis Keycloak vollständig gestartet ist
while ! curl -sSf http://localhost:8080/health; do
    echo "Waiting for Keycloak to start..."
    sleep 5
done

# Führe das Skript zum Anlegen des Realms und der Nutzer aus
/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user $KEYCLOAK_ADMIN --password $KEYCLOAK_ADMIN_PASSWORD
/opt/keycloak/bin/kcadm.sh create users -r ${REALM_NAME} -s username=$REALM_SERVICE_ACCOUNT_USERNAME -s enabled=true
USER_ID=$(/opt/keycloak/bin/kcadm.sh get users -r ${REALM_NAME} -q username=$REALM_SERVICE_ACCOUNT_USERNAME --fields id | grep -o '"id" : "[^"]*' | sed 's/"id" : "//')
/opt/keycloak/bin/kcadm.sh set-password -r ${REALM_NAME} --userid $USER_ID --new-password $REALM_SERVICE_ACCOUNT_PASSWORD

# Halte den Container am Laufen
tail -f /dev/null