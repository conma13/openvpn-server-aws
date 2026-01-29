#!/usr/bin/env bash

set -euo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1
echo "===== START Setup SSH at $(date) ====="

# Set SSH port number, default is 22
SSHPort="${1:-22}"

# Setup SSH
cat <<EOF > /etc/ssh/sshd_config.d/99-custom.conf
# --- Custom SSH hardening ---

# Non-standard SSH port
Port $SSHPort

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

echo "===== END Setup SSH at $(date) ====="
