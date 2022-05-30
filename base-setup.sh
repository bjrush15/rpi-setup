#!/bin/bash

CONFIG_DIR="configs"

echo " -- INSTALLING BASE APT PACKAGES --"
# install base tools
sudo apt install -y vim


echo " -- INSTALLING CONFIGS -- "
# move dot files into home directory
cp "$CONFIG_DIR/.bashrc" "$CONFIG_DIR/.bash_prompt" "$HOME"
# get immediate use of new .bashrc
source "$HOME/.bashrc"

echo " -- INSTALLING DOCKER -- "
# install docker via official install script
curl -sSL https://get.docker.com | sh
