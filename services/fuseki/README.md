<!--
SPDX-FileCopyrightText: 2024 University of Applied Sciences Osnabrück
SPDX-FileContributor: Andreas Schliebitz
SPDX-FileContributor: Henri Graf
SPDX-FileContributor: Jonas Tüpker
SPDX-FileContributor: Lukas Hesse
SPDX-FileContributor: Maik Fruhner
SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
SPDX-FileContributor: Tobias Wamhof

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Apache Jena Fuseki

## Build and run
```bash
DOCKER_BUILDKIT=1 docker build --build-arg JENA_VERSION=4.3.1 --build-arg JVM_ARGS="-Xmx8G" -t fuseki .

# Temporary container
docker run --rm \
  -p 3030:3030 \
  --name=fuseki fuseki

# Persistent container
docker run -d \
  -p 3030:3030 \
  --name=fuseki fuseki
```
