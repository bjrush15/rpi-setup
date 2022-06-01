from arm32v7/alpine

# install + update
run apk update && apk add git

# install cockpit from source
run git clone https://github.com/cockpit-project/cockpit "/cockpit"
workdir "/cockpit"
run make
run make install
workdir /

#cmd ["/bin/sh", "/start.sh"]

