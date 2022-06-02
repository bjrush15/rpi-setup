from arm32v7/alpine

# install + update
run apk update && apk add dnsmasq

# configure dnsmasq
add configs/dnsmasq.conf /etc/dnsmasq.conf

add configs/start.sh /start.sh
cmd ["/bin/sh", "/start.sh"]
