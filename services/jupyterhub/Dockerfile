# SPDX-FileCopyrightText: 2024 Osnabrück University of Applied Sciences
# SPDX-FileContributor: Andreas Schliebitz
# SPDX-FileContributor: Henri Graf
# SPDX-FileContributor: Jonas Tüpker
# SPDX-FileContributor: Lukas Hesse
# SPDX-FileContributor: Maik Fruhner
# SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
# SPDX-FileContributor: Tobias Wamhof
#
# SPDX-License-Identifier: MIT

ARG JUPYTERHUB_VERSION

FROM jupyterhub/jupyterhub:${JUPYTERHUB_VERSION}

COPY requirements.txt .

# Install dockerspawner
RUN python3 -m pip install \
    --no-cache-dir \
    -r requirements.txt

CMD ["jupyterhub", "-f", "/srv/jupyterhub/config/config.py"]
