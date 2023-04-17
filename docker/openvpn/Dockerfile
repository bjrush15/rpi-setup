from alpine:latest

# install + update
run apk update && apk upgrade && apk add openvpn iptables

# download nordvpn openvpn configs
run mkdir ovpn
run wget https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip
run unzip ovpn.zip
run sed -i 's|auth-user-pass|auth-user-pass /vpnlogin|' ovpn*/*

#run mkdir -p /dev/net
#run mknod /dev/net/tun c 10 200
#run chmod 600 /dev/net/tun

# copy and exec init
add start.sh /start.sh
add credentials /vpnlogin
add iptables.sh /iptables.sh
add iptables-off.sh /iptables-off.sh
cmd ["/bin/sh", "/start.sh"]
#cmd ["/bin/sleep", "6000000"]

