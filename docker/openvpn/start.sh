#!/bin/sh

mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
./iptables.sh
openvpn ovpn_udp/us9681.nordvpn.com.udp.ovpn
./iptables-off.sh
