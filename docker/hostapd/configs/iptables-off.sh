#!/bin/sh

# see instructions here for explaination
# https://fwhibbit.es/en/automatic-access-point-with-docker-and-raspberry-pi-zero-w

# bash logical OR &&
# First commant (-C) checks for the rule, second command adds it if it is missing
iptables-nft -t nat -C POSTROUTING -o eth0 -j MASQUERADE && iptables-nft -t nat -D POSTROUTING -o eth0 -j MASQUERADE

iptables-nft -C FORWARD -i eth0 -o wlan1 -m state --state RELATED,ESTABLISHED -j ACCEPT && iptables-nft -D FORWARD -i eth0 -o wlan1 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables-nft -C FORWARD -i wlan1 -o eth0 -j ACCEPT && iptables-nft -D FORWARD -i wlan1 -o eth0 -j ACCEPT
