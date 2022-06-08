#!/bin/sh

sudo docker run -d --restart="always" -p 61208-61209:61208-61209 -e GLANCES_OPT="-w" -v /var/run/docker.sock:/var/run/docker.sock:ro --pid host --net=host --privileged --name glances-docker-master glances-docker
