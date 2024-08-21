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

FORCE=false

usage() {
  echo "Usage: ${0} -d agri-gaia.{dev, localhost, ...} [ -f (force) ]"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

while getopts d:f OPT
do
  case "${OPT}" in
    d) DOMAIN="${OPTARG}";;
    f) FORCE=true;;
    \?)
      echo "Option '-$OPTARG' is not a valid option." >&2
      usage
      exit 1
      ;;
    : )
      echo "Option '-$OPTARG' needs an argument." >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "${FORCE}" != true ]] && [[ "${FORCE}" != false ]]; then
  echo "-f (force) is not a boolean value."
fi

if ls -A . | grep -q "${DOMAIN}" && [[ "${FORCE}" == false ]]; then
  echo "Certificates for ${DOMAIN} already exist."
  exit 2
fi

CURVE="secp384r1"
# See: ERR_CERT_VALIDITY_TOO_LONG (https://stackoverflow.com/a/65239775)
DAYS_VALID=397
SUBJECT="/CN=*.${DOMAIN}/O=Osnabrueck University of Applied Sciences/OU=Faculty of Engineering and Computer Science/L=Osnabrueck/ST=Lower Saxony/C=DE"

# See: https://stackoverflow.com/a/60516812
#################################
# Become a Certificate Authority
#################################

# Generate private key
openssl ecparam -name "${CURVE}" -genkey \
  -out "ca.${DOMAIN}.key"

# Generate root certificate
openssl req -x509 -new -nodes \
  -key "ca.${DOMAIN}.key" \
  -sha384 -days "${DAYS_VALID}" \
  -subj "${SUBJECT}" \
  -out "ca.${DOMAIN}.crt"

#########################
# Create CA-signed certs
#########################

# Generate a private key
openssl ecparam -name "${CURVE}" -genkey \
  -out "${DOMAIN}.key"

# Create a certificate-signing request
openssl req -new \
  -key "${DOMAIN}.key" \
  -subj "${SUBJECT}" \
  -out "${DOMAIN}.csr"

cat <<EOF > "${DOMAIN}.ext"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth,clientAuth
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${DOMAIN} 
DNS.2 = *.${DOMAIN} 
EOF

# Create the signed certificate
openssl x509 -req \
  -in "${DOMAIN}.csr" \
  -CA "ca.${DOMAIN}.crt" \
  -CAkey "ca.${DOMAIN}.key" -CAcreateserial \
  -out "${DOMAIN}.crt" -days "${DAYS_VALID}" -sha384 \
  -extfile "${DOMAIN}.ext"
