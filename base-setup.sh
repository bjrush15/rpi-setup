#!/bin/bash

NOCOLOR='\033[0m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

# pretty print function
# $SIGN - use to tell which symbol to prepend
#         CONT     [*] (blue)
#         GOOD     [+] (green)
#         BAD      [-] (red)
#         WARN     [!] (yellow)
# $MESSAGE - the message to print. FIRST word should be in all caps
#            FIRST word will also be yellow
function echo() {
  SIGN="$1"
  ECHO="$(which echo)"

  case "$SIGN" in
    "INFO")
      symbol="${CYAN}*"
      shift
      ;;
    "GOOD")
      symbol="${GREEN}+"
      shift
      ;;
    "BAD")
      symbol="${RED}-"
      shift
      ;;
    "WARN")
      symbol="${YELLOW}!"
      shift
      ;;
    *)
      symbol="${CYAN}*"
  esac
  MESSAGE="$@"

  eval "$ECHO" -e "$($ECHO -e $MESSAGE | sed 's/ / ${CYAN}/; s/^/${CYAN}\[${symbol}${CYAN}\]\ ${YELLOW}/; s/${NOCOLOR}/${CYAN}/; s/$/${NOCOLOR}/')" 
}



CONFIG_DIR="configs"
echo INFO "USING config dir $CONFIG_DIR"

echo INFO "INSTALLING base apt packages"
# install base tools
# vim - text editor
# dnsutils - provides dig/nslookup for DNS debug
# stress - simple CPU stress test tool (testing Glances)
sudo apt install -y vim dnsutils stress

# install realtek rtl8814au drivers (For Alfa AWUS1900 wireless card)
# instructions from https://davidtavarez.github.io/2018/re4son_kernel_raspberry_pi/
# custom kernel was not needed as of 6/7/22
if [[ ! -f "/lib/modules/$(uname -r)/kernel/drivers/net/wireless/88XXau.ko" ]]; then
  # Build prereqs
  sudo apt install -y raspberrypi-kernel-headers bc

  git clone https://github.com/aircrack-ng/rtl8812au "$HOME/rtl8812au"
  cd "$HOME/rtl8812au"
  echo INFO "BUILDING Realtek rtl8814au drivers"
  make RTL8814=1 ARCH=arm
  echo GOOD "INSTALLING Realtek rtl8814au drivers"
  sudo make install RTL8814=1 ARCH=arm
  cd -
else
  echo WARN "SKIPPING Realtek rtl8814au driver install - already installed"
fi

echo INFO "INSTALLING configs"
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
  echo GOOD "INSTALLING docker"
  curl -sSL https://get.docker.com | sh
else
  echo WARN "SKIPPING docker installation - already installed"
fi
