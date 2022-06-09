#!/bin/bash

sudo docker run --rm --privileged -v /mnt/nfsshare:/nfsshare -e SHARED_DIRECTORY=/nfsshare --name nfs-docker-master --net=host -d nfs-docker
