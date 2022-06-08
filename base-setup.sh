#!/bin/bash

CONFIG_DIR="configs"

echo " -- INSTALLING base apt packages --"
# install base tools
# vim - text editor
# dnsutils - provides dig/nslookup for DNS debug
sudo apt install -y vim dnsutils

# install realtek rtl8814au drivers (For Alfa AWUS1900 wireless card)
# instructions from https://davidtavarez.github.io/2018/re4son_kernel_raspberry_pi/
# custom kernel was not needed as of 6/7/22
if [[ -f "/lib/modules/$(uname -r)/kernel/drivers/net/wireless/88XXau.ko" ]]; then
  echo " -- INSTALLING Realtek rtl8814au drivers -- "
  sudo apt install -y raspberrypi-kernel-headers bc

  git clone https://github.com/aircrack-ng/rtl8812au "$HOME/rtl8812au"
  cd "$HOME/rtl8812au"
  echo " -- BUILDING rtl8814au drivers"
  make RTL8814=1 ARCH=arm
  echo " -- INSTALLING rtl8814au drivers"
  sudo make install RTL8814=1 ARCH=arm
  cd ../
else
  echo " -- SKIPPING Realtek rtl8814au driver install - already installed -- "
fi

echo " -- INSTALLING configs -- "
# move dot files into home directory
# .bashrc - bash config file
# .bash_prompt - sourced from .bashrc to set up a colorful prompt
cp -v "$CONFIG_DIR/.bashrc" "$CONFIG_DIR/.bash_prompt" "$HOME"
# .vimrc - vim configuration file
cp -v "$CONFIG_DIR/.vimrc" "$HOME"

# get immediate use of new .bashrc
source "$HOME/.bashrc"

# install docker via official install script if needed
if [[ -z `which docker` ]]; then
  echo " -- INSTALLING docker -- "
  curl -sSL https://get.docker.com | sh
else
  echo " -- SKIPPING docker installation - already installed -- "
fi
