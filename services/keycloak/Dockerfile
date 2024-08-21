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

# Stage 1 - Build
FROM maven:3.9.2-eclipse-temurin-11 AS build

COPY registration-hook-spi/src /home/app/src
COPY registration-hook-spi/pom.xml /home/app
RUN mvn -f /home/app/pom.xml clean package

# Stage 2 - Package
FROM quay.io/keycloak/keycloak:24.0.4

ARG PROJECT_BASE_URL
ARG REALM_NAME
ARG BACKEND_OPENID_CLIENT_SECRET
ARG PORTAINER_OPENID_CLIENT_SECRET
ARG JUPYTERHUB_OPENID_CLIENT_SECRET
ARG CVAT_KEYCLOAK_CLIENT_SECRET

WORKDIR /opt/keycloak

# add the registration hook listener
COPY --from=build /home/app/target/keycloak-registration-eventlistener.jar /opt/keycloak/providers 

# add the prometheus metrics api
COPY ./metrics-spi/keycloak-metrics-spi-5.0.0.jar /opt/keycloak/providers


###### BUILD ##############
RUN /opt/keycloak/bin/kc.sh build --features="docker" --health-enabled=true --db postgres
#########################

ADD --chown=root:root https://github.com/moparisthebest/static-curl/releases/latest/download/curl-amd64 /usr/bin/curl
USER root
RUN chmod +x /usr/bin/curl

# add the custom themes
COPY ./themes/ /opt/keycloak/themes/

# Copy in the realm-export to automatically init keycloak
RUN mkdir /opt/keycloak/data/import
COPY ./realm-export/realm-export.json /opt/keycloak/data/import/realm-export.json

# Customize Keycloak's realm-export.json to match the .env
RUN sed -i "\
    s/agri-gaia.localhost/${PROJECT_BASE_URL}/g; \
    s/test-realm/${REALM_NAME}/g; \
    s/BACKEND_OPENID_CLIENT_SECRET/${BACKEND_OPENID_CLIENT_SECRET}/g; \
    s/PORTAINER_OPENID_CLIENT_SECRET/${PORTAINER_OPENID_CLIENT_SECRET}/g; \
    s/JUPYTERHUB_OPENID_CLIENT_SECRET/${JUPYTERHUB_OPENID_CLIENT_SECRET}/g; \
    " /opt/keycloak/data/import/realm-export.json

ENV KEYCLOAK_IMPORT /opt/keycloak/data/import/realm-export.json
ENV KEYCLOAK_THEME agri-gaia
ENV REALM = REALM_NAME
ENV PROJECT_BASE_URL = PROJECT_BASE_URL

COPY startup.sh /opt/keycloak/bin/startup.sh
RUN chmod +x /opt/keycloak/bin/startup.sh

ENTRYPOINT ["/opt/keycloak/bin/startup.sh"]