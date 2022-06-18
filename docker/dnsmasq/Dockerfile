from alpine:latest

# install + update
run apk update && apk upgrade && apk add dnsmasq

# configure dnsmasq
add configs/dnsmasq.conf /etc/dnsmasq.conf
add configs/interfaces /etc/network/interfaces

add configs/start.sh /start.sh
cmd ["/bin/sh", "/start.sh"]
