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

The (new) Agri-Gaia platform based on docker-compose.

## Installation

### Prerequisites

1. Make sure Docker is installed and running:

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

2. Add yourself to the `docker` group in order to execute docker related commands without `sudo`:

```bash
sudo usermod -aG docker "${USER}"
newgrp docker
```

3. Clone this repository and `update --init` all submodules:

```bash
git clone git@platform.gitlab.hs-osnabrueck.de:agri-gaia/platform.git \
  && cd platform \
  && git submodule update --init --recursive
```

In this repository, there are three submodules:

-   [Backend](https://gitlab.edvsz.hs-osnabrueck.de/agri-gaia/backend) at `./services/backend`
-   [Frontend](https://gitlab.edvsz.hs-osnabrueck.de/agri-gaia/frontend) at `./services/frontend`
-   [Dockerfile Generator](https://github.com/agri-gaia/dockerfile-generator) at `./services/backend/dockerfile-generator`

There is another submodule inside the Dockerfile Generator at `./agri_gaia_dockerfile_generator/edge-inference-template` which is hosted in a private `agri-gaia` repository on GitHub.

Please make sure that you've access to all of these repositories and their submodule references point the "correct" commits. If in doubt, change into the submodule's directory and checkout its master branch for the latest changes:

```bash
git checkout master && git pull
```

## Deployment

### Profiles

Some services which are defined in the `docker-compose.yml` are annotated with one or more of the following four `profiles`:

-   `edge`: Services used for deloying containerized models onto edge devices.
-   `annoation`: Services used for annotating datasets.
-   `semantics`: Services used for semantic annotation and querying of datasets, models and containers.
-   `monitoring`: Services used for monitoring the platform's state (erors, resource consumption, etc.).

Profiles are used to prevent not needed services from starting up after issuing a `docker compose up` command. By selectively enabling certain services, you can for example lower startup times and reduce resource consumption in development.

Docker Compose will always start services which do not have a `profile` annoation. These services are considered to be vital for the platform to function. Profiles can be specified using the `COMPOSE_PROFILES` environment variable or via a flag to `docker compose up`:

```bash
# No need for --profile
export COMPOSE_PROFILES=edge,annotation,semantics,monitoring

# Start everything for development
docker compose \
  --profile edge \
  --profile annotation \
  --profile semantics \
  --profile monitoring \
  up -d --build

# Start everything except services for annoation and monitoring
docker compose \
  --profile edge \
  --profile semantics \
  up -d --build
```

### Additional resource files

The Eclipse Dataspace Connector (EDC) participates in a data space by authenticating against a central IdP of the data space. For this to work a Java Keystore file is needed. The keystore file must be placed in `secrets/edc/keystore.jks` so that the application finds the file.

### Development

For development, navigate to the location of the `docker-compose.yml` file and run:

```bash
docker compose up -d --build
```

You might have noticed the `.override.yml` file in this repo. Docker Compose automatically merges its contents into the main `docker-compose.yml`. The command above is hence a shorthand for:

```bash
docker compose -f docker-compose.yml -f docker-compose.override.yml up -d --build
```

Taking into account the ability to explicitly select which kind of SSL certificate (provider) should be used, the command above is itself a shorthand for:

```bash
docker compose \
  -f docker-compose.yml \
  -f docker-compose.override.yml \
  -f docker-compose-overrides/self-signed.yml \
  up -d --build
```

We support three different kinds of SSL certificates with appropriate overrides in the [docker-compose-overrides](./docker-compose-overrides) directory:

-   [Self-signed](./docker-compose-overrides/self-signed.yml): These [wildcard certificates](./config/traefik/certs/wildcard) for `*.agri-gaia.localhost` and `*.agri-gaia.dev` are used in development. They are based on elliptic curves over a 384 bit prime field (secp384r1) and [generated](./config/traefik/certs/self-signed/wildcard/generate.sh) using OpenSSL.
-   [Issued](./docker-compose-overrides/issued.yml): Trusted SSL certificate issued by a certificate authority other than Let's Encrypt. As for self-signed certificates, the name of the certificate and key must start with the `PROJECT_BASE_URL` (see [.env](./.env)) and end with `.key` or `.crt`. This is dictated by the overrides in [docker-compose-overrides](./docker-compose-overrides).
-   [Let's Encrypt](./docker-compose-overrides/lets-encrypt.yml): Traefik as our reverse proxy supports automatic Let's Encrypt certificate acquisiton and renewal as part of its built-in ACME (_Automatic Certificate Management Environment_) functionality.
-   [External Account Binding (EAB)](./docker-compose-overrides/http-acme-aeb.yml): This method also uses Traefik's ACME capabilities but with a custom Certificate Authority (CA). Certificate acquisition and renewal are perfomed over HTTP instead of DNS.

#### Developing on a remote machine

Due to the high RAM consumption of the platform, development on low performance systems, without the use of profiles, can be difficult or in some cases even impossible.

In these cases, it might be a good idea to use a more powerful computer inside your network for development purposes. Due to the `localhost` keyword under Linux always referring to the current device, configuration and use of another domain (`PROJECT_BASE_URL`) is required. The platform supports `*.agri-gaia.dev` as such an alternate domain out of the box.

In order to associate your development system's IP address (e. g. 192.168.xx.xx) with that domain, you'll have to add the following line with all the platform subdomains to your `/etc/hosts` file:

```bash
echo '192.168.xx.xx  app.agri-gaia.dev portainer.agri-gaia.dev edge.agri-gaia.dev keycloak.agri-gaia.dev registry.agri-gaia.dev minio-console.agri-gaia.dev minio.agri-gaia.dev cvat.agri-gaia.dev api.agri-gaia.dev webvowl.agri-gaia.dev fuseki.agri-gaia.dev traefik.agri-gaia.dev registry.agri-gaia.dev prometheus.agri-gaia.dev monitoring.agri-gaia.dev' | sudo tee -a /etc/hosts
```

After that, you'll have to deploy the platform on your development system using the `webhook` from the `platform-devtools` repository. To generate a suitable `curl-deploy.sh` you can use the `generate-curl-deploy.sh` script. Make sure not to generate new SSL certificates as the platform is shipped with pre-generated ones. Once the deployment process has started, Traefik will use the pre-generated self-signed SSL certificates for `agri-gaia.dev` from its [wildcard certs](./config/traefik/certs/self-signed/wildcard) directory. In order to avoid warnings about untrusted certificates, you'll have to add the `ca.agri-gaia.dev.crt` to your browser's trusted certificate authorities and `agri-gaia.dev.crt` to its trusted servers.

On your development system, change the ownership of everything inside `/etc/webhook` to your current user:

```bash
sudo chown -R user:user /etc/webhook
```

You can now work on the files inside of `/etc/webhook/git/agri-gaia/platform` with changes being applied in real-time to `app` and `api` if you deployed the platform in development mode.

**Warning**: Do not commit files like `.env` and Keycloak's `realm-export.json` into the `development` branch as they have been changed by the deployment itself. For example, the default `PROJECT_BASE_URL` string `localhost.agri-gaia` was replaced everywhere with `agri-gaia.dev`.

#### Startup

Docker Compose reads **insecure** credentials, which are meant to be used for development purposes only, from the hidden `.env` file.

You can monitor the deployment process in your terminal using `watch`:

```bash
watch -n 0.5 "docker ps -a"
```

After all containers are `Running`, visit [app.agri-gaia.localhost](https://app.agri-gaia.localhost) in your browser and read on.

By default, self-signed SSL certificates will be used in development by our reverse proxy Traefik. You'll have to accept the warnings generated by your browser regarding the use of untrusted certificates for each subdomain (e. g. [app](https://app.agri-gaia.localhost), [api](https://api.agri-gaia.localhost), [keycloak](https://keycloak.agri-gaia.localhost), [minio](https://minio.agri-gaia.localhost), etc.).

If you deployed the platform for the first time, you'll have to create a new user via Keycloak's register form upon first visit to the `app` subdomain. Subsequent deployments will read your user generated data from [Docker Volumes](https://docs.docker.com/storage/volumes/) which are used for persistance. They are never removed by default. If you really want to remove them, run the following:

```bash
docker compose down -v --remove-orphans
```

#### Testing Edge-Devices on the local instance

To test edge devices on the local deployment it is advised to use a VM for that. The following steps are necessary to setup the connection between the VM and Portainer:

For WSL2:

1. Add `--network=host` to the run command of the container
2. Add the WSL2 IP to the hosts file of the VM
    - check the WSL2 IP with `ip addr`
    - Add an entry for the following domain names to `/etc/hosts`
        - edge.agri-gaia.localhost
        - portainer.agri-gaia.localhost
        - registry.agri-gaia.localhost
        - keycloak.agri-gaia.localhost
3. Add the self signed certificate to the VM:
    - Copy the .crt file from `./config/traefik/certs/self-signed/wildcard/agri-gaia.localhost.crt` to the folder `/usr/local/share/ca-certificates/` of the VM
    - execute `sudo update-ca-certificates`

### Production

Real-world production deployment is handled entirely by the [Webhook](https://gitlab.edvsz.hs-osnabrueck.de/agri-gaia/platform-devtools/-/tree/master/webhook) in the [platform-devtools](https://gitlab.edvsz.hs-osnabrueck.de/agri-gaia/platform-devtools) repository. This project adds single-click deployment capabilities on a wide range of Linux based servers running `docker` and `docker compose`. If you intend to deploy this platform in production, please consult the Webhook's [README.md](https://gitlab.edvsz.hs-osnabrueck.de/agri-gaia/platform-devtools/-/blob/master/webhook/README.md) for further instructions.

You can deploy the platform locally in production mode with self-signed or issued certificates:

```bash
docker compose \
  -f docker-compose.yml \
  -f docker-compose.prod.yml \
  -f docker-compose-overrides/self-signed.yml \
  up -d --build
```

As you can see, the command for a production deployment is quite verbose. There are no "sensible" (working) shortand commands with implicit overrides and the like.

However, deploying locally in production mode doesn't make much sense. A production deployment outside the Webhook is hardly different from a development deployment. The platform will only work on `*.localhost` subdomains as specified by `PROJECT_BASE_URL` and the credentials will be still insecure. At this point, the only major difference is that both the Traefik dashboard and the web app will have HTTP basic authentication enabled.

## Uploading GeoData

You might need to install the postgis client inside the `postgis_backend` container:

```bash
apt update && apt install -y postgis
```

In the command below `public.nds_ud_22_s` points to the database schema `public` and table `nds_ud_22_s`. The `-d` option drops the database table before re-creating it with the supplied shape file data. For more information please consult the [shp2pgsql(1)](https://manpages.debian.org/bullseye/postgis/shp2pgsql.1.en.html) manpage.

```bash
shp2pgsql -d -s 25832 ./agri-gaia-open-data/geo/NDS/Schlaege_2022/ud_22_s.shp public.nds_ud_22_s \
  | psql postgresql://postgis:pass@postgis_backend:5432/postgis
```

GeoData is loaded automatically via the Webhook container during deployment if the `load_open_data` GET parameter is set to `true`.

### Removing GeoData

Field boundaries from Niedersachsen: `./agri-gaia-open-data/geo/NDS/Schlaege_2022`

```bash
docker exec agri_gaia-postgis_backend-1 psql \
    postgresql://postgis:pass@postgis_backend:5432/postgis \
        -c "DROP TABLE public.nds_ud_22_hwpfb;
            DROP TABLE public.nds_ud_22_hwple;
            DROP TABLE public.nds_ud_22_s;
            DROP TABLE public.nds_ud_22_ts;
            DROP TABLE public.nds_ud_22_tsle"
```
