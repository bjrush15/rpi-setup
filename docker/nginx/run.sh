#!/bin/bash

sudo docker run -d -it --rm -p 80:80 --net=host --name nginx-docker-master nginx-docker
