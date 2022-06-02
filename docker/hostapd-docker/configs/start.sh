#!/bin/sh

NOCOLOR='\033[0m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'

sigterm_handler() {
  echo -e "${CYAN}[*] Caught SIGTERM/SIGINT!${NOCOLOR}"
  pkill hostapd
  cleanup
  exit 0
}

cleanup (){
  echo -e "${CYAN}[*] Deleting iptables rules...${NOCOLOR}"
  sh /iptables-off.sh || echo -e "${RED}[-] Error deleting iptables rules${NOCOLOR}"
  echo -e "${CYAN}[*] Restarting network interface...${NOCOLOR}"
  ifdown wlan1
  ifup wlan1
  echo -e "${GREEN}[+] Successfully exited!${NOCOLOR}"
}

trap 'sigterm_handler' TERM INT
echo -e "${CYAN}[*] Creating iptables rules${NOCOLOR}"
sh /iptables.sh || echo -e "${RED}[-] Error creating iptables rules${NOCOLOR}"

echo -e "${CYAN}[*] Setting wlan1 settings${NOCOLOR}"
ifdown wlan1
ifup wlan1

echo -e "${CYAN}[+] Configuration successful! Services will start now${NOCOLOR}"
#dhcpd -4 -f -d wlan1 &
hostapd /etc/hostapd/hostapd.conf #&
#pid=$!
#wait $pid

cleanup
