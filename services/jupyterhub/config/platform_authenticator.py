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

import os
from oauthenticator.generic import GenericOAuthenticator

ROOT_URL = os.environ.get("ROOT_URL")
OAUTH_URL = os.environ.get("OAUTH_URL")
OAUTH_REALM = os.environ.get("OAUTH_REALM")
OAUTH_CLIENT_ID = os.environ.get("OAUTH_CLIENT_ID")
OAUTH_CLIENT_SECRET = os.environ.get("OAUTH_CLIENT_SECRET")


class PlatformAuthenticator(GenericOAuthenticator):
    def __init__(self, **kwargs) -> None:
        super(PlatformAuthenticator, self).__init__(**kwargs)

        self.client_id = OAUTH_CLIENT_ID
        self.client_secret = OAUTH_CLIENT_SECRET
        self.login_service = "SSO"

        self.authorize_url = (
            f"{OAUTH_URL}/realms/{OAUTH_REALM}/protocol/openid-connect/auth"
        )
        self.userdata_url = (
            f"{OAUTH_URL}/realms/{OAUTH_REALM}/protocol/openid-connect/userinfo"
        )
        self.token_url = (
            f"{OAUTH_URL}/realms/{OAUTH_REALM}/protocol/openid-connect/token"
        )
        self.oauth_callback_url = f"https://jupyterhub.{ROOT_URL}/hub/oauth_callback"
        self.logout_redirect_url = f"https://jupyterhub.{ROOT_URL}"

        self.username_key = "preferred_username"
        self.userdata_params = {"state": "state"}

        self.scope = ["openid", "profile", "roles", "email", "offline_access"]
        self.userdata_params = {"state": "state"}
        self.allow_all = True

        self.auto_login = True
        self.check_signature = True
        self.jwt_signing_algorithms = ["HS256", "RS256"]
        self.enable_auth_state = True
