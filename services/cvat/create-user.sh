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

USERNAME="${1}"
EMAIL="${2}"
PASSWORD="${3}"
FIRST_NAME="${4}"
LAST_NAME="${5}"

cat <<EOF | python3 "${HOME}/manage.py" shell && echo "User ${USERNAME} created!"
from django.contrib.auth.models import User
u = User.objects.create_user(username='${USERNAME}', email='${EMAIL}', password='${PASSWORD}')
u.first_name = '${FIRST_NAME}'
u.last_name = '${LAST_NAME}'
u.save()
EOF
