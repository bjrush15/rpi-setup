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
  echo -e "${GREEN}[+] Successfully exited!${NOCOLOR}"
}

trap 'sigterm_handler' TERM INT
echo -e "${CYAN}[+] Starting dnsmasq${NOCOLOR}"
dnsmasq --no-daemon --log-queries --log-facility=/dnsmasq.log &
pid=$!
wait $pid

cleanup
