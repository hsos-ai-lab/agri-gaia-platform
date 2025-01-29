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

##################################
### Build the portainer executable
##################################
FROM ubuntu:22.04 AS build-stage

ARG PORTAINER_EDITION="ce"
ARG PORTAINER_VERSION="2.19.5"

WORKDIR /work

# Set TERM as noninteractive to suppress debconf errors
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Set default go version
ARG GO_VERSION=go1.21.6.linux-amd64

# Install packages
RUN apt-get update --fix-missing && apt-get install -qq \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    git \
    make \
    g++ \
    coreutils \
    jq \
    gnupg-agent \
    software-properties-common

# Install NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get -y install yarn

# Install Golang
RUN cd /tmp \
    && wget -q https://go.dev/dl/${GO_VERSION}.tar.gz \
    && tar -C /usr/local -xzf ${GO_VERSION}.tar.gz

RUN git clone https://github.com/portainer/portainer.git \
    && cd portainer \
    && git checkout tags/${PORTAINER_VERSION}

WORKDIR /work/portainer

RUN sed -i 's/4\*time\.Minute/30\*time\.Minute/g' api/chisel/service.go

RUN bash -c 'PATH=$PATH:/usr/local/go/bin CONTAINER_IMAGE_TAG=${PORTAINER_VERSION} NODE_VERSION=$(node -v) YARN_VERSION=(yarn --version) WEBPACK_VERSION=5 GO_VERSION=$(go version) make build-all'
RUN bash -c 'CONTAINER_IMAGE_TAG=${PORTAINER_VERSION} NODE_VERSION=$(node -v) YARN_VERSION=(yarn --version) WEBPACK_VERSION=5 GO_VERSION=$(go version) make build-storybook'

##################################
### Create admin password for portainer
##################################
FROM httpd:2.4-alpine AS password-stage
ARG ADMIN_PASSWORD

# generate the hashed password
RUN mkdir -p /tmp && htpasswd -nbB admin $ADMIN_PASSWORD | cut -d ":" -f 2 | tr -d '\n'> /tmp/pass.txt

##################################
### Get come CLI tools
##################################
FROM busybox:1.34.1-uclibc AS busybox-stage

##################################
### build the portainer image
##################################
FROM portainer/base
LABEL org.opencontainers.image.title="Portainer" \
    org.opencontainers.image.description="Docker container management made simple, with the world’s most popular GUI-based container management platform." \
    org.opencontainers.image.vendor="Portainer.io" \
    com.docker.desktop.extension.api.version=">= 0.2.2" \
    com.docker.desktop.extension.icon="https://portainer-io-assets.sfo2.cdn.digitaloceanspaces.com/logos/portainer.png" \
    com.docker.extension.screenshots="[{\"alt\": \"screenshot one\", \"url\": \"https://portainer-io-assets.sfo2.digitaloceanspaces.com/screenshots/docker-extension-1.png\"},{\"alt\": \"screenshot two\", \"url\": \"https://portainer-io-assets.sfo2.digitaloceanspaces.com/screenshots/docker-extension-2.png\"},{\"alt\": \"screenshot three\", \"url\": \"https://portainer-io-assets.sfo2.digitaloceanspaces.com/screenshots/docker-extension-3.png\"},{\"alt\": \"screenshot four\", \"url\": \"https://portainer-io-assets.sfo2.digitaloceanspaces.com/screenshots/docker-extension-4.png\"},{\"alt\": \"screenshot five\", \"url\": \"https://portainer-io-assets.sfo2.digitaloceanspaces.com/screenshots/docker-extension-5.png\"},{\"alt\": \"screenshot six\", \"url\": \"https://portainer-io-assets.sfo2.digitaloceanspaces.com/screenshots/docker-extension-6.png\"},{\"alt\": \"screenshot seven\", \"url\": \"https://portainer-io-assets.sfo2.digitaloceanspaces.com/screenshots/docker-extension-7.png\"},{\"alt\": \"screenshot eight\", \"url\": \"https://portainer-io-assets.sfo2.digitaloceanspaces.com/screenshots/docker-extension-8.png\"},{\"alt\": \"screenshot nine\", \"url\": \"https://portainer-io-assets.sfo2.digitaloceanspaces.com/screenshots/docker-extension-9.png\"}]" \
    com.docker.extension.detailed-description="<p data-renderer-start-pos=\"226\">Portainer&rsquo;s Docker Desktop extension gives you access to all of Portainer&rsquo;s rich management functionality within your docker desktop experience.</p><h2 data-renderer-start-pos=\"374\">With Portainer you can:</h2><ul><li>See all your running containers</li><li>Easily view all of your container logs</li><li>Console into containers</li><li>Easily deploy your code into containers using a simple form</li><li>Turn your YAML into custom templates for easy reuse</li></ul><h2 data-renderer-start-pos=\"660\">About Portainer&nbsp;</h2><p data-renderer-start-pos=\"680\">Portainer is the worlds&rsquo; most popular universal container management platform with more than 650,000 active monthly users. Portainer can be used to manage Docker Standalone, Kubernetes, Docker Swarm and Nomad environments through a single common interface. It includes a simple GitOps automation engine and a Kube API.&nbsp;</p><p data-renderer-start-pos=\"1006\">Portainer Business Edition is our fully supported commercial grade product for business-wide use. It includes all the functionality that businesses need to manage containers at scale. Visit <a class=\"sc-jKJlTe dPfAtb\" href=\"http://portainer.io/\" title=\"http://Portainer.io\" data-renderer-mark=\"true\">Portainer.io</a> to learn more about Portainer Business and <a class=\"sc-jKJlTe dPfAtb\" href=\"http://portainer.io/take-3?utm_campaign=DockerCon&amp;utm_source=Docker%20Desktop\" title=\"http://portainer.io/take-3?utm_campaign=DockerCon&amp;utm_source=Docker%20Desktop\" data-renderer-mark=\"true\">get 3 free nodes.</a></p>" \
    com.docker.extension.publisher-url="https://www.portainer.io" \
    com.docker.extension.additional-urls="[{\"title\":\"Website\",\"url\":\"https://www.portainer.io?utm_campaign=DockerCon&utm_source=DockerDesktop\"},{\"title\":\"Documentation\",\"url\":\"https://docs.portainer.io\"},{\"title\":\"Support\",\"url\":\"https://join.slack.com/t/portainer/shared_invite/zt-txh3ljab-52QHTyjCqbe5RibC2lcjKA\"}]"

COPY --from=build-stage /work/portainer/dist/docker /
COPY --from=build-stage /work/portainer/dist/docker-compose /
COPY --from=build-stage /work/portainer/dist/helm /
COPY --from=build-stage /work/portainer/dist/kubectl /
COPY --from=build-stage /work/portainer/dist/mustache-templates /mustache-templates/
COPY --from=build-stage /work/portainer/dist/portainer /
COPY --from=build-stage /work/portainer/dist/public /public/

COPY --from=build-stage /work/portainer/build/docker-extension /

# storybook exists only in portainerci builds
COPY --from=build-stage /work/portainer/dist/storybook* /storybook/

VOLUME /data
WORKDIR /

EXPOSE 9000
EXPOSE 9443
EXPOSE 8000

LABEL io.portainer.server true

COPY --from=busybox-stage /bin/busybox /busybox
COPY --from=password-stage /tmp/pass.txt /pass.txt

# Set default admin password at startup
ENTRYPOINT [ "/busybox", "sh", "-c" , "/portainer --admin-password $(/busybox cat pass.txt) --edge-compute" ]
