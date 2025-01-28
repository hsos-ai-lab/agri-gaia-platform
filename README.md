<!--
SPDX-FileCopyrightText: 2024 University of Applied Sciences Osnabrück
SPDX-FileContributor: Andreas Schliebitz
SPDX-FileContributor: Henri Graf
SPDX-FileContributor: Jonas Tüpker
SPDX-FileContributor: Lukas Hesse
SPDX-FileContributor: Maik Fruhner
SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
SPDX-FileContributor: Tobias Wamhof

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Agri-Gaia Platform

The Agri-Gaia platform created by the Working Group of Prof. Tapken at the University of Applied Sciences Osnabrück

## Installation

The platform uses docker compose as deployment tool.

To run the platform your device should have at least 16GB RAM but 32GB RAM are recommended.

### Prerequisites

#### 1. Make sure Docker is installed and running:

```bash
sudo apt update \
  && sudo apt install ca-certificates curl gnupg lsb-release \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && sudo apt update \
  && sudo apt install -y --no-install-recommends \
    docker-ce docker-ce-cli containerd.io \
    docker-compose-plugin docker-buildx-plugin \
    jq zip unzip \
  && sudo systemctl enable --now docker
```

Optional: Add yourself to the `docker` group in order to execute docker related commands without `sudo`:

```bash
sudo usermod -aG docker "${USER}"
newgrp docker
```

#### 2. Clone this repository:

```bash
git clone https://github.com/hsos-ai-lab/agri-gaia-platform
```

#### 3. Initialize the submodules

In this repository, there are two submodules:

- [Backend](https://github.com/hsos-ai-lab/agri-gaia-backend) at `./services/backend`
- [Frontend](https://github.com/hsos-ai-lab/agri-gaia-frontend) at `./services/frontend`

Go into the cloned directory and initialize the backend and frontend submodules:

```bash
  cd agri-gaia-platform && git submodule update --init --recursive
```

### Additional resource files

The Eclipse Dataspace Connector (EDC) participates in a data space by authenticating against a central IdP of the data space. A Java Keystore file is needed to use this feature. The keystore file must be placed in `secrets/edc/keystore.jks` so that the application finds the file.

## Deployment

### Deployment in Production

To configure the platform deployment for different environments docker compose overrides are used. The base file is `docker-compose.yml` which is complemented by `docker-compose.override.yml` for a development build and `docker-compose.prod.yml` for the production build. For additional configurations e.g. SSL configuration and GPU configuration more override files are provided in the `docker-compose-overrides` directory. To ease the deployment of the platform for a production setup deployment scripts are provided in the [Platform Deployment](https://github.com/hsos-ai-lab/agri-gaia-platform-deployment) repository which includes an interactive setup script. Please inspect the Platform Deployment README.md file for instructions on how to deploy in production.

### Development

For a development build there are scripts provided in this repository:

- `start.sh`: Start the platform with all services
- `start-no-monitoring.sh`: Start the platform with all services except the monitoring services
- `stop.sh`: Stops the platform services. Use `stop.sh -v` to delete all docker volumes
- `run_tests.sh`: Run the platform tests

The configuration is mainly done using the environment variables the .env file.

We support three different kinds of SSL certificates with appropriate overrides in the [docker-compose-overrides](./docker-compose-overrides) directory:

- [Self-signed](./docker-compose-overrides/self-signed.yml): These [wildcard certificates](./secrets/certs/self-signed) for `*.agri-gaia.localhost` and `*.agri-gaia.dev` are used in development. They are based on elliptic curves over a 384 bit prime field (secp384r1) and [generated](./secrets/certs/self-signed/generate.sh) using OpenSSL.
- [Issued](./docker-compose-overrides/issued.yml): Trusted SSL [wildcard or multi-domain certificates](./secrets/certs/issued) issued by a certificate authority other than Let's Encrypt. As for self-signed certificates, the name of the certificate and key must start with the `PROJECT_BASE_URL` (see [.env](./.env)) and end with `.key` or `.crt`. This is dictated by the overrides in [docker-compose-overrides](./docker-compose-overrides).
- Let's Encrypt [DNS-01](./docker-compose-overrides/lets-encrypt-dns.yml)/[HTTP-01](./docker-compose-overrides/lets-encrypt-http.yml) via free [Duck DNS](`https://www.duckdns.org`) domain: Traefik as our reverse proxy supports automatic Let's Encrypt wildcard certificate acquisiton and renewal as part of its built-in ACME (_Automatic Certificate Management Environment_) functionality. Certificates and private keys are stored in [`acme.json`](./secrets/certs/acme) within the `secrets` directory.
- [External Account Binding (EAB)](./docker-compose-overrides/http-acme-aeb.yml): This method also uses Traefik's ACME capabilities but with a custom Certificate Authority (CA).

#### Startup

You can monitor the deployment process in your terminal using `watch`:

```bash
watch -n 0.5 "docker ps -a"
```

After all containers are `Running`, visit [app.agri-gaia.localhost](https://app.agri-gaia.localhost) in your browser and create the first user using the registration form.

By default, self-signed SSL certificates will be used in development by our reverse proxy Traefik. The certificates are located in [`./secrets/certs/self-signed`](`./secrets/certs/self-signed`) and have to be installed into your browser to prevent the browser from recognizing the server as insecure. If no certificates are present in [`./secrets/certs/self-signed`](`./secrets/certs/self-signed`) or the certificates have expired, run `./generate.sh -d agri-gaia.localhost -f` to generate new self-signed certificates.

#### Developing on a remote machine

Due to the high RAM consumption of the platform, development on low performance systems, without the use of profiles, can be difficult or in some cases even impossible.

In these cases, it might be a good idea to use a more powerful computer inside your network for development purposes. Due to the `localhost` keyword under Linux always referring to the current device, configuration and use of another domain (`PROJECT_BASE_URL`) is required. The platform supports `*.agri-gaia.dev` as such an alternate domain out of the box.

In order to associate your development system's IP address (e. g. 192.168.xx.xx) with that domain, you'll have to add the following line with all the platform subdomains to your `/etc/hosts` file:

```bash
echo '192.168.xx.xx  app.agri-gaia.dev portainer.agri-gaia.dev edge.agri-gaia.dev keycloak.agri-gaia.dev registry.agri-gaia.dev minio-console.agri-gaia.dev minio.agri-gaia.dev cvat.agri-gaia.dev nuclio.agri-gaia.dev api.agri-gaia.dev webvowl.agri-gaia.dev fuseki.agri-gaia.dev traefik.agri-gaia.dev registry.agri-gaia.dev prometheus.agri-gaia.dev monitoring.agri-gaia.dev jupyterhub.agri-gaia.dev edc-provider.agri-gaia.dev edc-provider-web.agri-gaia.dev edc-provider-ids.agri-gaia.dev' | sudo tee -a /etc/hosts
```

After that, you'll have to deploy the platform on your development system using the `platform-deployment` repository. To generate a suitable configuration you can use the `setup-env.sh` script. Once the deployment process has started, Traefik will use the self-signed SSL certificates for `agri-gaia.dev` from the [secrets](./secrets/certs/self-signed) directory. In order to avoid warnings about untrusted certificates, you'll have to add the `ca.agri-gaia.dev.crt` to your browser's trusted certificate authorities and `agri-gaia.dev.crt` to its trusted servers.

You can now work on the files inside of `/opt/agri-gaia/platform` with changes being applied in real-time to `app` and `api` if you deployed the platform in development mode.

**Warning**: Do not commit files like `.env` and Keycloak's `realm-export.json` into the `development` branch as they have been changed by the deployment itself. For example, the default `PROJECT_BASE_URL` string `localhost.agri-gaia` was replaced everywhere with `agri-gaia.dev`.

#### Testing Edge-Devices on the local instance

To test edge devices on the local deployment it is advised to use a VM for that. The following steps are necessary to setup the connection between the VM and Portainer:

For running the platform in WSL2 and the edge agent in a linux VM:

1. Add the WSL2 IP to the hosts file of the VM
   - check the WSL2 IP with `ip addr`
   - Add an entry for the following domain names to `/etc/hosts`
     - edge.agri-gaia.localhost
     - portainer.agri-gaia.localhost
     - registry.agri-gaia.localhost
     - keycloak.agri-gaia.localhost
2. Add the self signed certificate to the VM:
   - Copy the .crt file from `./secrets/certs/self-signed/agri-gaia.localhost.crt` to the folder `/usr/local/share/ca-certificates/` of the VM
   - execute `sudo update-ca-certificates`
3. Add `--network=host` to the run command of the edge agent container and run the container
