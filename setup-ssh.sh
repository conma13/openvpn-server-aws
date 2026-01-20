#!/bin/bash

cat <<'EOF' > /etc/ssh/sshd_config.d/99-custom.conf
# --- Custom SSH hardening ---

# Non-standard SSH port
Port 2222

# Key‑based authentication only
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
HostKeyAlgorithms ssh-ed25519,ssh-rsa
PubkeyAcceptedAlgorithms ssh-ed25519,ssh-rsa
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512,hmac-sha2-256

# Verbose logging
LogLevel VERBOSE

# Limit time allowed for login attempts
LoginGraceTime 20

# Limit the number of authentication attempts
MaxAuthTries 3

# Disallow system banners
PrintMotd no
PrintLastLog yes
EOF