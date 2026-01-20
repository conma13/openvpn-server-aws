#!/bin/bash

# Update system
apt update -y
apt upgrade -y

# Install requirements
apt install -y sudo curl ca-certificates gnupg ufw

# Setup SSH
cat <<'EOF' > /etc/ssh/sshd_config.d/99-custom.conf
# --- Custom SSH hardening ---

# Non-standard SSH port
Port 2222

# Key-based authentication only
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes

# Disable root login
PermitRootLogin no

# Disallow empty passwords
PermitEmptyPasswords no

# Enforce protocol version 2
Protocol 2

# Strong and modern cryptographic algorithms
HostKeyAlgorithms ssh-ed25519
PubkeyAcceptedAlgorithms ssh-ed25519
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512,hmac-sha2-256

# Verbose logging
LogLevel VERBOSE

# Limit time allowed for login attempts
LoginGraceTime 20

# Limit the number of authentication attempts
MaxAuthTries 3

# Limit user access
AllowUsers admin

# Disable X11 forwarding
X11Forwarding no

# Disable agent forwarding
AllowAgentForwarding no

# Disable TCP forwarding
AllowTcpForwarding no

# Use strict mode for Authorized keys
StrictModes yes

# Limit the maximum number of concurrent unauthenticated connections
MaxStartups 3:30:100

# Disallow system banners
PrintMotd no
PrintLastLog yes
EOF

# Restart ssh
systemctl restart ssh

# Allow new SSH port in firewall
ufw allow 2222/tcp
ufw --force enable

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
usermod -aG docker admin
