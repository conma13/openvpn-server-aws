#!/usr/bin/env bash

set -euo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1
echo "===== START Bootstrap at $(date) ====="

# Check the script URL presence
ScriptsURL="${1:?ScriptsURL is not set}"
echo "BOOTSTRAP Path to scripts is: ${ScriptsURL}"

# Check or create temp dir
TMPDIR="${2:-}"
if ! ( cd "$TMPDIR" 2>/dev/null && [[ ! -r . && ! -w . ]] ); then
   TMPDIR=$(mktemp -d)
   trap "rm -rf '$TMPDIR'" EXIT
   cd "$TMPDIR"
fi
echo "BOOTSTRAP Using temp dir: ${TMPDIR}"

# Set SSH port number, default is 22
SSHPort="${3:-22}"

# System update and initial setup
echo "BOOTSTRAP Downloading system setup script: ${ScriptsURL}/setup-system.sh"
curl -fLO "${ScriptsURL}/setup-system.sh"
chmod +x setup-system.sh
echo "BOOTSTRAP Running setup-system.sh"
./setup-system.sh

# Setup SSH
echo "BOOTSTRAP Downloading script to setup SSH: ${ScriptsURL}/setup-ssh.sh"
curl -fLO "${ScriptsURL}/setup-ssh.sh"
chmod +x setup-ssh.sh
echo "BOOTSTRAP Running setup-ssh.sh"
./setup-ssh.sh "$SSHPort"

# Setup firewall
echo "BOOTSTRAP Downloading script to setup firewall: ${ScriptsURL}/setup-firewall.sh"
curl -fLO "${ScriptsURL}/setup-firewall.sh"
chmod +x setup-firewall.sh
echo "BOOTSTRAP Running setup-firewall.sh"
./setup-firewall.sh "$SSHPort"

echo "===== END Bootstrap at $(date) ====="
