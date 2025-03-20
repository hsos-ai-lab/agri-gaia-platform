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

FROM eclipse-temurin:17

ARG PROJECT_BASE_URL
ARG CONNECTOR_PASSWORD
ARG MINIO_ROOT_USER
ARG MINIO_ROOT_PASSWORD
ARG KEYSTORE_PASSWORD

RUN useradd -ms /bin/bash admin

WORKDIR /home

RUN wget https://github.com/hsos-ai-lab/agri-gaia-platform-assets/releases/download/v0.1/provider.jar -O /home/provider.jar

COPY config.properties vault.properties /home/

RUN sed -i "\
    s,CONNECTOR_PASSWORD,${CONNECTOR_PASSWORD},g; \
    " /home/config.properties

RUN sed -i "\
    s,EDC_PROVIDER_IDS_URL,https://edc-provider-ids.${PROJECT_BASE_URL},g; \
    " /home/config.properties

RUN sed -i "\
    s/MINIO_ROOT_USER/${MINIO_ROOT_USER}/g; \
    s/MINIO_ROOT_PASSWORD/${MINIO_ROOT_PASSWORD}/g; \
    " /home/vault.properties

RUN chown -R admin:admin /home
RUN chmod -R 777 /home
USER admin

ENV KEYSTORE_PASSWORD_ENV=${KEYSTORE_PASSWORD}

ENTRYPOINT java -Dedc.fs.config=/home/config.properties -Dedc.keystore=/home/secrets/keystore.jks -Dedc.keystore.password=${KEYSTORE_PASSWORD_ENV} -Dedc.vault=/home/vault.properties -jar /home/provider.jar
