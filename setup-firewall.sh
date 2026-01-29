#!/usr/bin/env bash

set -euo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1
echo "===== START Firewall Setup at $(date) ====="

# Set SSH port number, default is 22
SSHPort="${1:-22}"

# Allow new SSH port in firewall
ufw allow $SSHPort/tcp
ufw --force enable

echo "===== END Firewall Setup at $(date) ====="
