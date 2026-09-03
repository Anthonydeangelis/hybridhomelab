#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

wazuh_version="${WAZUH_VERSION:-4.14}"
installer="wazuh-install.sh"

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates

curl -sO "https://packages.wazuh.com/${wazuh_version}/${installer}"
bash "./${installer}" -a

echo "WAZUH01 is installed. Save the generated admin password in a local password manager, not in this repository."
echo "Keep the Wazuh dashboard private to the homelab network."
