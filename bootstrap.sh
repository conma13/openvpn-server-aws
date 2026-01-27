#!/usr/bin/env bash

set -euo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1
echo "===== Bootstrap started at $(date) ====="

# Check the script URL presence
ScriptsURL="${1:?ScriptsURL is not set}"
echo "Path to scripts is: ${ScriptsURL}"

# Check or create temp dir
TMPDIR="${2:-}"
if ! ( cd "$TMPDIR" 2>/dev/null && [[ ! -r . && ! -w . ]] ); then
   TMPDIR=$(mktemp -d)
   trap "rm -rf '$TMPDIR'" EXIT
   cd "$TMPDIR"
fi
echo "Using temp dir: ${TMPDIR}"

echo "Downloading install script: ${ScriptsURL}/install.sh"
curl -fLO "${ScriptsURL}/install.sh"
chmod +x install.sh
echo "Running install.sh"
./install.sh

echo "===== Bootstrap finished at $(date) ====="
