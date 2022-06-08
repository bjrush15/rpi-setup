#!/bin/sh

sudo docker run --rm --name dnsmasq-docker-master --cap-add=NET_ADMIN --network=host -d dnsmasq-docker
