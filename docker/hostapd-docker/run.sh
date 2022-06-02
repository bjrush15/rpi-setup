#!/bin/sh

sudo docker run --name hostapd-docker-master --cap-add=NET_ADMIN --network=host -d hostapd-docker
