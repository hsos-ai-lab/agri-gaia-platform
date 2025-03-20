<!--
SPDX-FileCopyrightText: 2024 Osnabrück University of Applied Sciences
SPDX-FileContributor: Andreas Schliebitz
SPDX-FileContributor: Henri Graf
SPDX-FileContributor: Jonas Tüpker
SPDX-FileContributor: Lukas Hesse
SPDX-FileContributor: Maik Fruhner
SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
SPDX-FileContributor: Tobias Wamhof

SPDX-License-Identifier: MIT
-->

# WebVOWL

Visualize ontologies in an interactive Web-UI.

## Build and run

```bash
DOCKER_BUILDKIT=1 docker build --build-arg WEBVOWL_VERSION=1.1.7 -t webvowl .

# Temporary container
docker run --rm \
  -p 8080:8080 \
  --name=webvowl webvowl

# Persistent container
docker run --d \
  -p 8080:8080 \
  --name=webvowl webvowl
```
