#!/bin/bash

CONFIG_DIR="configs"

echo " -- INSTALLING BASE APT PACKAGES --"
# install base tools
sudo apt install -y vim

# install realtek rtl8814au drivers (Alfa AWUS1900 wireless card)
sudo apt install -y dkms build-essential libelf-dev linux-headers-`uname -r`

git clone https://github.com/aircrack-ng/rtl8814au
cd rtl8814au
sudo make dkms_install
cd ../

echo " -- INSTALLING CONFIGS -- "
# move dot files into home directory
cp "$CONFIG_DIR/.bashrc" "$CONFIG_DIR/.bash_prompt" "$HOME"
# get immediate use of new .bashrc
source "$HOME/.bashrc"

echo " -- INSTALLING DOCKER -- "
# install docker via official install script
curl -sSL https://get.docker.com | sh
