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

FROM cvat/server:v2.4.2

ARG S3FS_VERSION=1.91
ARG NUCLIO_VERSION=1.18.14
ARG PROJECT_BASE_URL='agri-gaia.localhost'

USER root

COPY create-superuser.sh /create-superuser.sh
RUN chmod +x /create-superuser.sh

COPY change-user-password.sh /change-user-password.sh
RUN chmod +x /change-user-password.sh

COPY create-user.sh /create-user.sh
RUN chmod +x /create-user.sh

COPY mount-minio-bucket.sh /home/django/mount-minio-bucket.sh
RUN chmod +x /home/django/mount-minio-bucket.sh

RUN apt-get -y update
RUN apt-get --no-install-recommends install -y kmod fuse wget \
      checkinstall automake g++ make libcurl4-openssl-dev libxml2-dev \
      openssl pkg-config libfuse-dev libssl-dev git tree

RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git s3fs-fuse
RUN cd s3fs-fuse && git fetch --all --tags && git checkout "tags/v$S3FS_VERSION" && \
      ./autogen.sh && ./configure && make && \
      checkinstall --install=yes -y --pkgversion="$(grep Version ChangeLog | head -n1 | cut -d' ' -f2)" && \
      cd ../ && rm -rf s3fs-fuse/

RUN sed -i '/user_allow_other/s/^#//g' /etc/fuse.conf

USER django

ENV DJANGO_SETTINGS_MODULE "cvat.settings.production"

RUN echo "SESSION_COOKIE_DOMAIN='.${PROJECT_BASE_URL}'" >> ./cvat/settings/base.py
RUN echo "CSRF_COOKIE_DOMAIN='.${PROJECT_BASE_URL}'" >> ./cvat/settings/base.py
RUN echo "CSRF_TRUSTED_ORIGINS=['.${PROJECT_BASE_URL}']" >> ./cvat/settings/base.py

COPY supervisord.conf .
