#!/usr/bin/env bash
set -e

# Using: ./install.sh vpn.example.com admin@example.com

DOMAIN="$1"
EMAIL="$2"

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
  echo "Usage: $0 <domain> <email>"
  exit 1
fi

echo "=== Creating directory structure ==="
mkdir -p openvpn-data stunnel certs vhost html

echo "=== Writing stunnel.conf ==="
cat > stunnel/stunnel.conf <<EOF
pid = /var/run/stunnel.pid
foreground = yes
debug = 3

[openvpn]
accept = 8443
connect = openvpn:1194
cert = /etc/stunnel/certs/${DOMAIN}.crt
key  = /etc/stunnel/certs/${DOMAIN}.key
CAfile = /etc/stunnel/certs/${DOMAIN}.chain.pem
verifyChain = yes
EOF

echo "=== Writing docker-compose.yml ==="
cat > docker-compose.yml <<EOF
version: "3.8"

services:
  nginx-proxy:
    image: jwilder/nginx-proxy:alpine
    container_name: nginx-proxy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./certs:/etc/nginx/certs:ro
      - ./vhost:/etc/nginx/vhost.d
      - ./html:/usr/share/nginx/html
    networks:
      - vpnnet

  letsencrypt:
    image: jrcs/letsencrypt-nginx-proxy-companion
    container_name: letsencrypt
    restart: unless-stopped
    environment:
      - NGINX_PROXY_CONTAINER=nginx-proxy
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./certs:/etc/nginx/certs
      - ./vhost:/etc/nginx/vhost.d
      - ./html:/usr/share/nginx/html
    networks:
      - vpnnet

  stunnel:
    image: alpine/stunnel
    container_name: stunnel
    restart: unless-stopped
    environment:
      - VIRTUAL_HOST=${DOMAIN}
      - VIRTUAL_PORT=8443
      - LETSENCRYPT_HOST=${DOMAIN}
      - LETSENCRYPT_EMAIL=${EMAIL}
    volumes:
      - ./stunnel/stunnel.conf:/etc/stunnel/stunnel.conf:ro
      - ./certs:/etc/stunnel/certs:ro
    networks:
      - vpnnet

  openvpn:
    image: kylemanna/openvpn
    container_name: openvpn
    restart: unless-stopped
    volumes:
      - ./openvpn-data:/etc/openvpn
    networks:
      - vpnnet

networks:
  vpnnet:
    driver: bridge
EOF

echo "=== Generating OpenVPN server config ==="
docker run -v $PWD/openvpn-data:/etc/openvpn --rm kylemanna/openvpn \
  ovpn_genconfig -u tcp://127.0.0.1

echo "=== Initializing PKI ==="
docker run -v $PWD/openvpn-data:/etc/openvpn --rm -it kylemanna/openvpn \
  ovpn_initpki

echo "=== Starting Docker stack ==="
docker compose up -d

echo "=== Waiting for Let's Encrypt to issue certificates ==="
sleep 15
docker logs letsencrypt | tail -n 20

if [ ! -f "certs/${DOMAIN}.crt" ]; then
  echo "ERROR: Certificate not found. Check DNS and port 80."
  exit 1
fi

echo "=== Creating first client certificate (client1) ==="
docker run -v $PWD/openvpn-data:/etc/openvpn --rm -it kylemanna/openvpn \
  easyrsa build-client-full client1 nopass

echo "=== Exporting client1.ovpn ==="
docker run -v $PWD/openvpn-data:/etc/openvpn --rm kylemanna/openvpn \
  ovpn_getclient client1 > client1.ovpn

echo "=== DONE ==="
echo "Your client config is ready: client1.ovpn"
echo "Use it with stunnel client on port 1194 → ${DOMAIN}:443"