#!/bin/sh

NOCOLOR='\033[0m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'

sigterm_handler() {
  echo -e "${CYAN}[*] Caught SIGTERM/SIGINT!${NOCOLOR}"
  pkill dnsmasq
  cleanup
  exit 0
}

cleanup (){
  echo -e "${CYAN}[*] Cleaning up routes${NOCOLOR}"
  ip route del 192.168.70.0/24
  echo -e "${CYAN}[*] Resetting interface eth1${NOCLOR}"
  ifdown eth1
  ifup eth1
  echo -e "${GREEN}[+] Successfully exited!${NOCOLOR}"
}

trap 'sigterm_handler' TERM INT

echo -e "${CYAN}[*] Setting eth1 settings${NOCOLOR}"
ifdown eth1
ifup eth1
ip route add 192.168.70.0/24 via 192.168.70.1 dev eth1

echo -e "${CYAN}[+] Starting dnsmasq${NOCOLOR}"
dnsmasq --no-daemon --log-queries --log-facility=/dnsmasq.log &
pid=$!
wait $pid

cleanup
