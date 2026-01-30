#!/usr/bin/env bash

docker run -v $PWD/openvpn-data:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u tcp://127.0.0.1
docker run -v $PWD/openvpn-data:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki