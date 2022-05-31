from arm32v7/alpine

# install + update
run apk update && apk add hostapd iw dhcp vim iptables

# configure hostapd
add configs/hostapd.conf /etc/hostapd/hostapd.conf

# configure dhcpcd
add configs/dhcpcd.conf /etc/dhcp/dhcpd.conf
run touch /var/lib/dhcp/dhcpd.leases

# configure networking
add configs/interfaces /etc/network/interfaces
add configs/iptablels.sh /iptables.sh
add configs/iptables-off.sh /iptables-off.sh

# copy and exec init
add configs/start.sh /start.sh
cmd ["/bin/sh", "/start.sh"]

