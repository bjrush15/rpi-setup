#!/bin/bash

function dump-args() {
  echo
  echo
  echo GOOD PARAMETERS:
  echo "HOSTNAME        $HOSTNAME"
  echo "DO_APT_UPDATE   $DO_APT_UPDATE"
  echo "DO_APT_UPGRADE  $DO_APT_UPGRADE"
  echo "ADMIN_USER      $ADMIN_USER"
  echo "ADMIN_HOME      $ADMIN_HOME"
  echo "CONFIG_DIR      $CONFIG_DIR"
  echo "AUTO_REBOOT     $AUTO_REBOOT"
}

# enable pretty-printing by override echo builtin
. pretty-echo.sh

# make sure we're running as root
echo INFO "I am $(whoami)"
if [[ "$UID" -ne "0" ]]; then
  echo WARN "REQUESTING \${RED}ROOT\${NOCOLOR} access"
  exec sudo "$0" "$@"
  exit 0
fi

# PARAMETERS
HOSTNAME="greenhouse"
DO_APT_UPGRADE=1
DO_APT_UPDATE=1
ADMIN_USER=admin
ADMIN_HOME="$(eval builtin echo ~$ADMIN_USER)"
AUTO_REBOOT=0

# handle arguments
while [ $# -gt 0 ]; do
  case "$1" in 
    --no-apt-update)
      DO_APT_UPDATE=0;;
    --no-apt-upgrade)
      DO_APT_UPGRADE=0;;
    --hostname=*)
      HOSTNAME=${1#*=};;
    --admin-username=*)
      ADMIN_USER=${1#*=}
      ADMIN_HOME="$(eval echo ~$ADMIN_USER)" ;;
    --auto-reboot)
      AUTO_REBOOT=1;;
    *)
      echo BAD "UNKNOWN argument $1 - exiting"
      exit 1
      ;;
  esac
  shift
done

CONFIG_DIR="$ADMIN_HOME/rpi-setup/configs"
dump-args

if [ "$DO_APT_UPDATE" = 1 ]; then
  echo INFO "UPDATING apt sources"
  apt update
fi

if [ "$DO_APT_UPGRADE" = 1 ]; then
  echo INFO "UPGRADING base system"
  apt upgrade -y
fi

echo INFO "INSTALLING base apt packages"
# install base tools
# stress - simple CPU stress test tool (testing Glances)
apt install -y vim tmux stress dnsutils

# install realtek rtl8814au drivers (For Alfa AWUS1900 wireless card)
# instructions from https://davidtavarez.github.io/2018/re4son_kernel_raspberry_pi/
# custom kernel was not needed as of 6/7/22
if [[ ! -f "/lib/modules/$(uname -r)/kernel/drivers/net/wireless/88XXau.ko" ]]; then
  # Build prereqs
  apt install -y raspberrypi-kernel-headers bc
  git clone https://github.com/aircrack-ng/rtl8812au "$ADMIN_HOME"
  cd "$ADMIN_HOME/rtl8812au"
  echo INFO "BUILDING Realtek rtl8814au drivers"
  make RTL8814=1
  echo GOOD "INSTALLING Realtek rtl8814au drivers"
  make install RTL8814=1
  cd -
else
  echo WARN "SKIPPING Realtek rtl8814au driver install - already installed"
fi

echo INFO "INSTALLING configs"
# move dot files into home directory
# .bashrc - bash config file
# .bash_prompt - sourced from .bashrc to set up a colorful prompt
cp -v "$CONFIG_DIR/.bashrc" "$CONFIG_DIR/.bash_prompt" "$ADMIN_HOME"
# .vimrc - vim configuration file
cp -v "$CONFIG_DIR/.vimrc" "$ADMIN_HOME"

# get immediate use of new .bashrc
. "$ADMIN_HOME/.bashrc"

# install docker via official install script if needed
if [[ -z `which docker` ]]; then
  echo GOOD "INSTALLING docker"
  curl -sSL https://get.docker.com | sh
else
  echo WARN "SKIPPING docker installation - already installed"
fi

echo INFO "CHECKING IPv6 settings"
if grep "ipv6\.disable=1" /boot/cmdline.txt; then
  echo GOOD "IPv6 already disabled"
else
  echo INFO "DISABLING IPv6"
  sed -i 's/$/ ipv6.disable=1/' /boot/cmdline.txt
fi

echo INFO "SETTING hostname to $HOSTNAME"
builtin echo "$HOSTNAME" > /etc/hostname

echo INFO "ENABLE IPv4 forwarding"
sed -i 's/#net.ipv4.ip_forward/net.ipv4.ip_forward/' /etc/sysctl.conf

echo INFO "DISABLING builtin wireless \(wlan0\)"
rfkill block 0

if grep "denyinterfaces wlan1 eth1" /etc/dhcpcd.conf; then 
  echo INFO "SKIPPING disabling dhcp on eth1/wlan1 - already disabled"
else
  echo INFO "DISABLE DHCP on wlan1 \(external wireless\) and eth1 \(USB ethernet\)"
  builtin echo "denyinterfaces wlan1 eth1" >> /etc/dhcpcd.conf
fi

echo INFO "Setting up nameserver configuration"
cp -v $CONFIG_DIR/resolv.conf /etc/resolv.conf

echo GOOD "DONE! Reboot for all changes to take effect"
if [ "$AUTO_REBOOT" = 1 ]; then
  echo GOOD "REBOOTING now"
  reboot
fi
