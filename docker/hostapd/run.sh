#!/bin/bash

sudo docker run --rm --name hostapd-docker-master --cap-add=NET_ADMIN --network=host -d hostapd-docker
