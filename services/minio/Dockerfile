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

ARG MINIO_IMAGE_TAG="RELEASE.2024-08-03T04-33-23Z"
FROM minio/minio:"${MINIO_IMAGE_TAG}"

COPY wait-for-keycloak.sh .

ENTRYPOINT [ "./wait-for-keycloak.sh", "/usr/bin/docker-entrypoint.sh" ]
