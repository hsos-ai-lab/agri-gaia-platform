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
PASSWORD="${2}"

echo "from django.contrib.auth.models import User; u = User.objects.get(username='${USERNAME}'); u.set_password('${PASSWORD}'); u.save();" | python3 "${HOME}/manage.py" shell && \
  echo "Changed password for user ${USERNAME}!"
