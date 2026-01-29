#!/usr/bin/env bash

set -euo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1
echo "===== START System Setup at $(date) ====="

# Update system
apt update -y
apt upgrade -y

# Install requirements
apt install -y sudo ca-certificates gnupg ufw

echo "===== END System Setup at $(date) ====="
