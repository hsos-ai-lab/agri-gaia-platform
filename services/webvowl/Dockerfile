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

FROM tomcat:9.0-jre8-alpine

ARG WEBVOWL_VERSION=1.1.7
ARG OWL2VOWL_VERSION=0.3.7
ARG DEFAULT_ONTOLOGY_NAME="agri-gaia-onto"

RUN apk update && apk upgrade && \
    apk add --no-cache zip

WORKDIR /usr/local/tomcat/webapps

RUN rm -rf ./*
COPY ./services/webvowl/webvowl_1.1.7.war ROOT.war

RUN mkdir ROOT && unzip ROOT.war -d ROOT && rm ROOT.war

WORKDIR /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/static

# Set default ontology to display
RUN sed -i "s/foaf/${DEFAULT_ONTOLOGY_NAME}/g" js/webvowl.app.js

RUN rm -rf data/*

COPY ./services/webvowl/index.html .

# Copy private ontologies from host to image
RUN mkdir -p ontologies/

COPY ./config/fuseki/ontologies/agri-gaia ontologies/
COPY ./config/fuseki/ontologies/gaia-x ontologies/

WORKDIR /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/static/ontologies

# Download public ontologies
# ARG GAIAX_SELF_DESCRIPTIONS_URL="https://gaia-x.gitlab.io/gaia-x-community/gaia-x-self-descriptions"

#RUN wget -O gaiax-core.ttl "${GAIAX_SELF_DESCRIPTIONS_URL}/core/ontology.ttl" \
#&& wget -O gaiax-resource.ttl "${GAIAX_SELF_DESCRIPTIONS_URL}/resource/ontology.ttl" \
#&& wget -O gaiax-contract.ttl "${GAIAX_SELF_DESCRIPTIONS_URL}/contract/ontology.ttl" \
#&& wget -O gaiax-node.ttl "${GAIAX_SELF_DESCRIPTIONS_URL}/node/ontology.ttl" \
#&& wget -O gaiax-participant.ttl "${GAIAX_SELF_DESCRIPTIONS_URL}/participant/ontology.ttl" \
#&& wget -O gaiax-service.ttl "${GAIAX_SELF_DESCRIPTIONS_URL}/service/ontology.ttl"

COPY ./services/webvowl/owl2vowl.jar .

# Convert all Turtle files (*.ttl) to WebVOWL JSON files
RUN find . -type f -name '*.ttl' | xargs -I {} java -jar owl2vowl.jar -file {}

RUN mv *.json ../data && cd .. && rm -rf ontologies/

WORKDIR /usr/local/tomcat/webapps

RUN zip -r ROOT.war ROOT

WORKDIR /usr/local/tomcat/bin
CMD ["catalina.sh", "run"]
