#!/bin/sh

sudo docker run --name dnsmasq-docker-master --cap-add=NET_ADMIN --network=host -d hostapd-docker
