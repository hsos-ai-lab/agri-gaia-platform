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
# SPDX-License-Identifier: AGPL-3.0-or-later

MINIO_ENDPOINT="${1}"
BUCKET_NAME="${2}"
DATASET_ID="${3}"

BUCKET_MOUNTPOINT="${HOME}/s3fs/${BUCKET_NAME}"
DATASET_SHARE_PATH="${HOME}/share/${BUCKET_NAME}"

# If BUCKET_NAME is not mounted, mount it after killing its s3fs process
if ! grep -q "${BUCKET_NAME} fuse.s3fs" /proc/mounts; then
  pkill -9 -f "s3fs ${BUCKET_NAME}"

  mkdir -p "${BUCKET_MOUNTPOINT}"
  
  # Note: To unmount use 'fusermount -u "${BUCKET_MOUNTPOINT}"'
  s3fs "${BUCKET_NAME}" "${BUCKET_MOUNTPOINT}" \
    -o host="http://${MINIO_ENDPOINT}" \
    -o ssl_verify_hostname=0 \
    -o use_path_request_style \
    -o allow_other || exit 10
fi

mkdir -p "${DATASET_SHARE_PATH}"

# Create symlink from CVAT's share folder into the bucket's s3fs mountpoint.
if [[ ! -h "${DATASET_SHARE_PATH}" ]]; then
  ln -s "${BUCKET_MOUNTPOINT}/datasets/${DATASET_ID}" "${DATASET_SHARE_PATH}" || exit 11
fi

tree "${DATASET_SHARE_PATH}"
