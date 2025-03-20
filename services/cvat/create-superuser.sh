#!/usr/bin/env bash

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

python3 "${HOME}/manage.py" createsuperuser --email "${CVAT_SUPERUSER_EMAIL}" --username "${CVAT_SUPERUSER}" --noinput && \
  /bin/bash /change-user-password.sh "${CVAT_SUPERUSER}" "${CVAT_SUPERUSER_PASSWORD}"
