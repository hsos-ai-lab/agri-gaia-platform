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

FROM registry:2
ARG KEYCLOAK_REALM_NAME

RUN apk add --no-cache curl jq gettext
RUN mkdir -p ./script/init

COPY . ./script/init
RUN sed -i "s/test-realm/${KEYCLOAK_REALM_NAME}/g" ./script/init/get_keycloak_cert.sh

ENTRYPOINT ["./script/init/get_keycloak_cert.sh", "registry"]
CMD ["serve", "/etc/docker/registry/config.yml"]
