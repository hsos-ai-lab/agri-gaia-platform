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
from dockerspawner import DockerSpawner
import docker

BASE_DIR = "/srv/jupyterhub/config"
GPU_DEVICE_IDS = os.environ.get("GPUS")
NGC_IMAGE_TAG = os.environ.get("NGC_IMAGE_TAG")
JUPYTERHUB_VERSION = os.environ.get("JUPYTERHUB_VERSION")
NETWORK_NAME = os.environ["DOCKER_NETWORK_NAME"]
PROJECT_NAME = os.environ["PROJECT_NAME"]

# First, define a custom spawner class to make the worker node selectable
class PlatformSpawner(DockerSpawner):
    def __init__(self, **kwargs) -> None:
        self.prefix = f"{PROJECT_NAME}-jupyter"
        super(PlatformSpawner, self).__init__(**kwargs)
        
        # Connect containers to this Docker network
        self.use_internal_ip = True
        self.network_name = NETWORK_NAME
        #self.name_template = "{prefix}-{username}-{servername}"

        # Spawn containers from one of these images
        self.allowed_images = {
            "data-science": f"agri-gaia/datascience-notebook:hub-{JUPYTERHUB_VERSION}",
            "base": f"agri-gaia/minimal-notebook:hub-{JUPYTERHUB_VERSION}",
        }

        # Set the spawned container config
        self.extra_host_config = {
            'network_mode': NETWORK_NAME,
            'shm_size': '8G',
            "cap_add": ["SYS_ADMIN"],
            "devices": ["/dev/fuse:/dev/fuse"],
            "privileged": True 
        }

        
        if GPU_DEVICE_IDS != "":
            self.extra_host_config['device_requests'] = [
                docker.types.DeviceRequest(
                    count=-1 if GPU_DEVICE_IDS=="all" else None,
                    device_ids=[GPU_DEVICE_IDS] if GPU_DEVICE_IDS != "all" else None,
                    capabilities=[["gpu"]],
                ),
            ]
            self.allowed_images["pytorch"] = f"agri-gaia/jupyterhub-notebook-pytorch:{NGC_IMAGE_TAG}"
            self.allowed_images["tf2"] = f"agri-gaia/jupyterhub-notebook-tf2:{NGC_IMAGE_TAG}"


        notebook_container_dir = f"{os.path.expanduser('~')}/work"
        notebook_volume_name = PROJECT_NAME + "-jupyterhub-user-{username}"
        self.notebook_dir = os.path.expanduser('~')
        self.cmd = ["jupyterhub-singleuser", "--ip=0.0.0.0"]

        # Mount the real user's Docker volume on the host to the notebook user's
        # notebook directory in the container
        self.volumes = { 
            notebook_volume_name: {
                "bind": notebook_container_dir, 
                "mode": "rw"
            }
        }

        self.default_url = '/lab'

        # Remove containers once they are stopped
        self.remove = True

        # For debugging arguments passed to spawned containers
        self.debug = False

