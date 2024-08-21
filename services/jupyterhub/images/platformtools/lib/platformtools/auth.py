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

import os
import json
import requests
from .constants import AUTH_FILE_PATH

def fetch_auth_tokens():
    url = f"{os.environ.get('JUPYTERHUB_API_URL')}/users/{os.environ.get('JUPYTERHUB_USER')}"
    headers = {"Authorization": f"token {os.environ.get('JUPYTERHUB_API_TOKEN')}"}
    r = requests.get(url, headers=headers)
    with open(AUTH_FILE_PATH, mode='wb') as authfile:
        authfile.write(r.content)

# Access Token
def load_tokens():
    with open(AUTH_FILE_PATH, "r") as f:
        auth = json.load(f)
        return auth["auth_state"]

def get_access_token():
    return load_tokens()["access_token"]

class BackendAuth(requests.auth.AuthBase):
    def __call__(self, r):
        r.headers["authorization"] = "Bearer " + get_access_token()
        return r
