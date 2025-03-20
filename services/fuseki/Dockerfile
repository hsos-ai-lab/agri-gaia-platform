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

FROM amazoncorretto:21-alpine3.18-jdk AS base

ARG JENA_VERSION="4.10.0"

RUN apk add --no-cache curl binutils

WORKDIR "/fuseki"

RUN wget https://repo1.maven.org/maven2/org/apache/jena/apache-jena-fuseki/$JENA_VERSION/apache-jena-fuseki-$JENA_VERSION.zip && \
    unzip apache-jena-fuseki-$JENA_VERSION.zip && \
    mv apache-jena-fuseki-$JENA_VERSION/* . && \
    rm -rf apache-jena-fuseki-$JENA_VERSION && \
    rm apache-jena-fuseki-$JENA_VERSION.zip && \
    sed -i '/^JVM_ARGS=/d' /fuseki/fuseki-server && \
    mkdir -p databases/DB2

ARG JDEPS_EXTRA="jdk.crypto.cryptoki,jdk.crypto.ec"
RUN \
    JDEPS="$(jdeps --multi-release base --print-module-deps --ignore-missing-deps fuseki-server.jar)"  && \
    jlink \
    --compress 2 --strip-debug --no-header-files --no-man-pages \
    --output /opt/java-minimal \
    --add-modules "${JDEPS},${JDEPS_EXTRA}"

RUN adduser -H -D fuseki fuseki

FROM alpine:3.18

ARG FUSEKI_ADMIN_USER=user
ARG FUSEKI_ADMIN_PASSWORD=pass
ARG JVM_ARGS

COPY --from=base /opt/java-minimal /opt/java-minimal
COPY --from=base /fuseki /fuseki
COPY --from=base /etc/passwd /etc/passwd

COPY shiro.ini /fuseki/run/shiro.ini
RUN sed -i \
    -e "s/user\[user\]/user[${FUSEKI_ADMIN_USER}]/g" \
    -e "s/user=pass/${FUSEKI_ADMIN_USER}=${FUSEKI_ADMIN_PASSWORD}/g" \
    /fuseki/run/shiro.ini
COPY config.ttl /fuseki/run/configuration/config.ttl

WORKDIR "/fuseki/run/configuration"
RUN mkdir ./datasets && wget https://github.com/hsos-ai-lab/agri-gaia-platform-assets/releases/download/v0.1/geonames.nt -O ./datasets/geonames.nt

RUN \
    wget https://agrovoc.fao.org/latestAgrovoc/agrovoc_lod.nt.zip &&\
    unzip ./agrovoc_lod.nt.zip -d ./temp &&\
    mkdir ./agrovoc &&\
    mv ./temp/* ./agrovoc/agrovoc.nt &&\
    rm -r ./temp &&\
    rm ./agrovoc_lod.nt.zip

WORKDIR "/fuseki"

RUN \
    mkdir -p /fuseki/logs && \
    mkdir -p /fuseki/databases && \
    chown -R fuseki /fuseki && \
    chmod a+x fuseki-server && \
    chmod a+x fuseki-backup && \
    chmod a+x fuseki

ENV \
    JAVA_HOME="/opt/java-minimal" \
    JENA_VERSION="${JENA_VERSION}" \
    FUSEKI_DIR="/fuseki" \
    JVM_ARGS="${JVM_ARGS}"

COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

USER fuseki

EXPOSE 3030

# In memory: --verbose --debug --mem /ds
# Persistent: --verbose --debug --tdb2 --update --loc databases/DB2 /ds
ENTRYPOINT ["./fuseki-server", "--verbose", "--debug", "--tdb2", "--update", "--loc", "databases/DB2", "/ds"]
