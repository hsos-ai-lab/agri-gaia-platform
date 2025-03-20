#!/usr/bin/env bash

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

usage() {
  echo "Usage: ${0} -t OID_ACCESS_TOKEN -s HOST -b BUCKET_NAME -m MOUNTPOINT"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

while getopts t:s:b:m: OPT
do
  case "${OPT}" in
    t) OID_ACCESS_TOKEN="${OPTARG}";;
    s) HOST="${OPTARG}";;
    b) BUCKET_NAME="${OPTARG}";;
    m) MOUNTPOINT="${OPTARG}";;
    \?)
      echo "Option '-$OPTARG' is not a valid option." >&2
      usage
      exit 2
      ;;
    : )
      echo "Option '-$OPTARG' needs an argument." >&2
      usage
      exit 3
      ;;
  esac
done

if [[ ! -d "${MOUNTPOINT}" ]]; then
  mkdir -p "${MOUNTPOINT}"
  echo "Mount directory '${MOUNTPOINT}' created."
fi

# Get S3 credentials via WebIdentity and OIDC access token
# See: https://docs.min.io/minio/baremetal/security/openid-external-identity-management/AssumeRoleWithWebIdentity.html
S3_CREDENTIALS=$(curl -s -k -X POST \
  -d 'Action=AssumeRoleWithWebIdentity' \
  -d "WebIdentityToken=${OID_ACCESS_TOKEN}" \
  -d 'DurationSeconds=604800' \
  -d 'Version=2011-06-15' \
  "${HOST}" \
  | sed '2 s/xmlns=".*"//g' \
  | xmllint --xpath '/AssumeRoleWithWebIdentityResponse/AssumeRoleWithWebIdentityResult/Credentials' - 2>/dev/null)

if [[ -z "${S3_CREDENTIALS}" ]]; then
  echo "Error: S3 server '${HOST}' did not return S3 credentials for given OIDC access token."
  exit 4
fi

# Extract individual keys
ACCESS_KEY=$(echo "${S3_CREDENTIALS}" | xmllint --xpath '//AccessKeyId/text()' - 2>/dev/null)
SECRET_KEY=$(echo "${S3_CREDENTIALS}" | xmllint --xpath '//SecretAccessKey/text()' - 2>/dev/null)
SESSION_TOKEN=$(echo "${S3_CREDENTIALS}" | xmllint --xpath '//SessionToken/text()' - 2>/dev/null)
EXPIRATION=$(echo "${S3_CREDENTIALS}" | xmllint --xpath '//Expiration/text()' - 2>/dev/null)

if [[ -z "${ACCESS_KEY}" ]] || [[ -z "${SECRET_KEY}" ]] || [[ -z "${SESSION_TOKEN}" ]]; then
  echo "Error: S3 server '${HOST}' returned incomplete WebIdentity XML result."
  exit 5
fi

echo "S3 access expires on ${EXPIRATION}."

# Create directory for AWS compliant credentials file (supported by s3fs)
mkdir -p "${HOME}/.aws"

AWS_PROFILE="dataset"

# Assemble ${AWS_PROFILE} entry for AWS credentials file
AWS_DATA_SHARING_ENTRY=$(cat << EOF
[${AWS_PROFILE}]
aws_access_key_id=${ACCESS_KEY}
aws_secret_access_key=${SECRET_KEY}
aws_session_token=${SESSION_TOKEN}
EOF
)

# Check if user already has a "${AWS_PROFILE}" entry in his AWS credentials file
AWS_CREDENTIALS="${HOME}/.aws/credentials"
if [[ -f "${AWS_CREDENTIALS}" ]] && grep -q "\[${AWS_PROFILE}\]" "${AWS_CREDENTIALS}"; then
  # Remove old "${AWS_PROFILE}" entry from existing credentials file
  echo "Removing existing '${AWS_PROFILE}' profile from AWS credentials file '${AWS_CREDENTIALS}'"
  sed -i "/\[${AWS_PROFILE}\]/,+3d" "${AWS_CREDENTIALS}"
fi

# Create AWS credentials file if needed and append "${AWS_PROFILE}" entry
echo "${AWS_DATA_SHARING_ENTRY}" >> "${AWS_CREDENTIALS}"

# Mount S3 bucket
s3fs "${BUCKET_NAME}" "${MOUNTPOINT}" \
	-o host="${HOST}" \
	-o profile="${AWS_PROFILE}" \
	-o parallel_count=8 \
	-o multipart_size=128 \
	-o use_path_request_style \
	-o allow_other

echo "Mounted bucket '${BUCKET_NAME}' from '${HOST}' into container at '${MOUNTPOINT}'."
