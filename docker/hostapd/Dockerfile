from arm32v7/alpine

# install + update
run apk update && apk add hostapd iptables

# configure hostapd
add configs/hostapd.conf /etc/hostapd/hostapd.conf

# configure networking
add configs/interfaces /etc/network/interfaces
add configs/iptables.sh /iptables.sh
add configs/iptables-off.sh /iptables-off.sh

# copy and exec init
add configs/start.sh /start.sh
cmd ["/bin/sh", "/start.sh"]

