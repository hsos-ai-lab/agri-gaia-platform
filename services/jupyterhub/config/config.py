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

# Configuration file for JupyterHub
c = get_config()


# helper func to import sibling files:
def import_class_from_file(class_name, file_name):
    with open(f"/srv/jupyterhub/config/{file_name}.py") as f:
        g = dict()
        exec(f.read(), g)
        return g[class_name]


#### Authentication ####
PlatformAuthenticator = import_class_from_file(
    "PlatformAuthenticator", "platform_authenticator"
)
c.JupyterHub.authenticator_class = PlatformAuthenticator


#### SPAWNER ####
PlatformSpawner = import_class_from_file("PlatformSpawner", "platform_spawner")
c.JupyterHub.spawner_class = PlatformSpawner


#### GENERIC CONF ####

# User containers will access hub by container name on the Docker network
c.JupyterHub.hub_ip = "0.0.0.0"
c.JupyterHub.hub_connect_ip = "jupyterhub"

# Persist hub data on volume mounted inside container
c.JupyterHub.cookie_secret_file = "/data/jupyterhub_cookie_secret"
c.JupyterHub.db_url = "sqlite:////data/jupyterhub.sqlite"

c.JupyterHub.allow_named_servers = True
c.JupyterHub.cleanup_servers = True

# Override Server Rules to allow a user to read their own auth_state
c.JupyterHub.load_roles = [
    {
        "name": "user",
        "description": "User Role for accessing auth_state via API",
        "scopes": ["self", "admin:auth_state!user"],
    },
    {
        "name": "server",
        "description": "Allows parties to start and stop user servers",
        "scopes": [
            "access:servers!user",
            "read:users:activity!user",
            "users:activity!user",
            "admin:auth_state!user",
        ],
    },
]
