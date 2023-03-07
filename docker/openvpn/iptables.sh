#!/bin/sh

# see instructions here for explaination
# https://fwhibbit.es/en/automatic-access-point-with-docker-and-raspberry-pi-zero-w

# bash logical OR ||
# First commant (-C) checks for the rule, second command adds it if it is missing
rule="POSTROUTING -o tun0 -j MASQUERADE"
iptables-nft -t nat -C $rule || iptables-nft -t nat -A $rule

rule="FORWARD -i tun0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT"
iptables-nft -C $rule || iptables-nft -A $rule

rule="FORWARD -i eth1 -o tun0 -j ACCEPT" 
iptables-nft -C $rule || iptables-nft -A $rule
