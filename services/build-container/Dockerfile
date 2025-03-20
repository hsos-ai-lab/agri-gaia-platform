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

FROM alpine as config_stage

RUN apk update && apk add jq moreutils

ARG NVIDIA_NGC_API_KEY

WORKDIR /root
COPY config.json add-nvidia-key.sh ./
RUN ./add-nvidia-key.sh config.json "$NVIDIA_NGC_API_KEY"

FROM docker:24-dind

# download qemu plugins for buildkit
RUN cd /usr/local/bin && \
    wget https://github.com/moby/buildkit/releases/download/v0.11.2/buildkit-v0.11.2.linux-amd64.tar.gz && \
    tar -xzf buildkit-v0.11.2.linux-amd64.tar.gz && \
    mv bin/buildkit-qemu-* . && \
    rm buildkit-v0.11.2.linux-amd64.tar.gz && \
    rm -r bin

RUN mkdir /root/.docker
COPY --from=config_stage /root/config.json /root/.docker/config.json