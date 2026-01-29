#!/usr/bin/env bash

set -euo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1
echo "===== START Docker Setup at $(date) ====="

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Update repository
apt update -y

# Install docker and requirements
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add admin user to docker group
# TODO(conma): Not sure that this is necessary
usermod -aG docker admin

echo "===== END Docker Setup at $(date) ====="
