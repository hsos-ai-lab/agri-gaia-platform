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

FROM alpine AS config

ARG NVIDIA_NGC_API_KEY

RUN apk update
RUN apk add jq moreutils

WORKDIR /root

COPY config.json add-nvidia-key.sh ./
RUN ./add-nvidia-key.sh config.json "${NVIDIA_NGC_API_KEY}"

FROM docker:27-dind

ARG BUILDKIT_VERSION=0.15.2

# download qemu plugins for buildkit
WORKDIR /usr/local/bin

RUN wget "https://github.com/moby/buildkit/releases/download/v${BUILDKIT_VERSION}/buildkit-v${BUILDKIT_VERSION}.linux-amd64.tar.gz"
RUN tar -xzf "buildkit-v${BUILDKIT_VERSION}.linux-amd64.tar.gz"
RUN mv bin/buildkit-qemu-* .
RUN rm buildkit-v${BUILDKIT_VERSION}.linux-amd64.tar.gz
RUN rm -r bin

RUN mkdir /root/.docker
COPY --from=config /root/config.json /root/.docker/config.json

WORKDIR /
