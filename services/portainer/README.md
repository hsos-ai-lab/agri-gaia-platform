<!--
SPDX-FileCopyrightText: 2024 Osnabrück University of Applied Sciences
SPDX-FileContributor: Andreas Schliebitz
SPDX-FileContributor: Henri Graf
SPDX-FileContributor: Jonas Tüpker
SPDX-FileContributor: Lukas Hesse
SPDX-FileContributor: Maik Fruhner
SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
SPDX-FileContributor: Tobias Wamhof

SPDX-License-Identifier: MIT
-->

## Installing the Edge Agent

Do these steps to associate a new Portainer Edge Agent with the Platform:

Use the [API-Documentation](https://app.swaggerhub.com/apis/portainer/portainer-ce/2.14.2)

1. [Authenticate](https://app.swaggerhub.com/apis/portainer/portainer-ce/2.14.2#/auth/AuthenticateUser) against the Portainer API as admin

2. Create a [new Endpoint / Environment](https://app.swaggerhub.com/apis/portainer/portainer-ce/2.14.2#/endpoints/EndpointCreate) using the Server URL `https://portainer.agri-gaia.localhost` and any name.

3. Grab the Edge_Key from the result and do the following:

- Decode it with base64
- Replace the second part of the string with `edge.agri-gaia.localhost:8000`
- Encode it to base64 and remove trailing `==` if any.

4. Run the following command on the Edge Device to associate:

```bash
export EDGE_ID=<random-uuid>
export EDGE_KEY=<the-edited-key>

docker run -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    -v /:/host \
    -v portainer_agent_data:/data \
    --restart always \
    -e EDGE=1 \
    -e EDGE_ID=$EDGE_ID \
    -e EDGE_KEY=$EDGE_KEY \
    -e CAP_HOST_MANAGEMENT=1 \
    -e EDGE_INSECURE_POLL=1 \
    --name portainer_edge_agent \
    portainer/agent:2.14.0
```

5. Test the Agent via the UI or API!
