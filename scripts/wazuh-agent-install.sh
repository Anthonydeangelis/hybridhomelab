#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo $0 <wazuh-manager-private-ip-or-hostname>" >&2
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo "Usage: sudo $0 <wazuh-manager-private-ip-or-hostname>" >&2
  exit 64
fi

manager="$1"
apt-get update
apt-get install -y curl gpg
curl -fsSL https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor --batch --yes -o /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" >/etc/apt/sources.list.d/wazuh.list
apt-get update
WAZUH_MANAGER="$manager" apt-get install -y wazuh-agent
systemctl enable --now wazuh-agent
echo 'Wazuh agent installed. Confirm enrollment in the private Wazuh dashboard.'
