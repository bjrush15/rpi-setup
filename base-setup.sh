#!/bin/bash
set -e

# PARAMETERS
HOSTNAME="greenhouse"
SKIP_APT_PACKAGES=0
SKIP_APT_UPDATE=0
DO_APT_UPGRADE=1
ADMIN_USER=admin
ADMIN_HOME="$(eval builtin echo ~$ADMIN_USER)"
CONFIG_DIR="$ADMIN_HOME/rpi-setup/configs"
DATA_DIR="/data"

# enable pretty-printing by override echo builtin
. pretty-echo.sh


function main() {
  ensure-root $@
  parse-args $@
  dump-args
  handle-apt
  install-realtek-wifi-driver
  install-and-activate-dot-files
  install-docker
  configure-network-settings
  create-all-users
  
  launch-docker-containers
  echo GOOD "DONE! Reboot for all changes to take effect"
}


function parse-args() {
  # handle arguments
  params="$(getopt -o "" --long skip-apt-packages:,skip-apt-update:,do-apt-upgrade:,hostname:,admin-username:,config-dir:,data-dir: -n base-setup.sh -- "$@")"
  eval set -- "$params"
  unset params

  while true; do
    case "$1" in 
      --skip-apt-packages)
        SKIP_APT_PACKAGES=$2
        shift 2;;
      --skip-apt-update)
        SKIP_APT_UPDATE=$2
        shift 2;;
      --do-apt-upgrade)
        DO_APT_UPGRADE=$2
        shift 2;;
      --hostname)
        HOSTNAME=$2
        shift 2;;
      --admin-username)
        ADMIN_USER=$2
        ADMIN_HOME="$(eval builtin echo ~/$ADMIN_USER)"
        shift 2;;
      --config-dir)
        CONFIG_DIR=$2
        shift 2;;
      --data-dir)
        DATA_DIR=$2
        shift 2;;
      --)
        shift
        break;;
      *)
        echo BAD "UNKNOWN argument $1 - exiting"
        exit 1;;
    esac
  done
}



function dump-args() {
  echo GOOD PARAMETERS:
  echo "HOSTNAME          $HOSTNAME"
  echo "SKIP_APT_UPDATE   $SKIP_APT_UPDATE"
  echo "DO_APT_UPGRADE    $DO_APT_UPGRADE"
  echo "SKIP_APT_PACKAGES $SKIP_APT_PACKAGES"
  echo "ADMIN_USER        $ADMIN_USER"
  echo "ADMIN_HOME        $ADMIN_HOME"
  echo "CONFIG_DIR        $CONFIG_DIR"
  echo "DATA_DIR       $DATA_DIR"
}



function ensure-root() {
  # make sure we're running as root
  if [[ "$UID" -ne "0" ]]; then
    exec sudo "$0" $@
    exit 0
  fi
}



function handle-apt() {
  if [ "$SKIP_APT_UPDATE" = 0 ]; then
    apt update
  fi
  if [ "$DO_APT_UPGRADE" = 1 ]; then
    apt upgrade
  fi
  if [[ "$SKIP_APT_PACKAGES" = 0 ]]; then
    # install base tools
    # vim - cli text editor
    # tmux - virtual terminal emulator
    # stress - simple CPU stress test tool (testing Glances)
    # dnsutils - dig for dns testing
    # acl - access control list management (for user permissions)
    # tvnamer - automatically name tv shows to nice names from unholy title
    # traceroute - network testing
    apt install -y vim tmux stress dnsutils acl tvnamer traceroute
  fi
}



function install-realtek-wifi-driver() {
  # install realtek rtl8814au drivers (For Alfa AWUS1900 wireless card)
  # instructions from https://davidtavarez.github.io/2018/re4son_kernel_raspberry_pi/
  # custom kernel was not needed as of 6/7/22
  if [[ ! -f "/lib/modules/$(uname -r)/kernel/drivers/net/wireless/88XXau.ko" || "$1" = "force" ]]; then
    # Build prereqs
    apt install -y raspberrypi-kernel-headers bc
    git clone https://github.com/aircrack-ng/rtl8812au "$ADMIN_HOME/rtl8812au"
    cd "$ADMIN_HOME/rtl8812au"
    echo INFO "BUILDING Realtek rtl8814au drivers"
    make RTL8814=1
    echo GOOD "INSTALLING Realtek rtl8814au drivers"
    make install RTL8814=1
    cd -
  else
    echo INFO "SKIPPING Realtek rtl8814au driver install - already installed"
  fi
}



function install-and-activate-dot-files() {
  echo INFO "INSTALLING configs"
  # move dot files into home directory
  cp -vr "$CONFIG_DIR"/* "$ADMIN_HOME"
  # get immediate use of new .bashrc
. "$ADMIN_HOME/.bashrc"
}




function install-docker() {
  # install docker via official install script if needed
  if [[ -z `which docker` || "$1" = "force" ]]; then
    echo GOOD "INSTALLING docker"
    curl -sSL https://get.docker.com | sh
  else
    echo WARN "SKIPPING docker installation - already installed"
  fi

  usermod -aG docker "$ADMIN_USER"
  echo INFO "$ADMIN_USER added to docker group for non-root control. Log out and back in to finalize"
}



function configure-network-settings() {
  disable-ipv6
  set-hostname
  enable-ipv4-forwarding
  disable-builtin-wlan
  disable-dhcp-on-controlled-interfaces
  enable-local-dns-server
}


function disable-ipv6() {
  echo INFO "CHECKING IPv6 settings"
  if grep "ipv6\.disable=1" /boot/cmdline.txt; then
    echo GOOD "IPv6 already disabled"
  else
    echo INFO "DISABLING IPv6"
    sed -i 's/$/ ipv6.disable=1/' /boot/cmdline.txt
  fi
}



function set-hostname() {
  echo INFO "SETTING hostname to $HOSTNAME"
  builtin echo "$HOSTNAME" > /etc/hostname
}



function enable-ipv4-forwarding() {
  echo INFO "ENABLING IPv4 forwarding"
  sed -i 's/#net.ipv4.ip_forward/net.ipv4.ip_forward/' /etc/sysctl.conf
}


function disable-builtin-wlan() {
  # TODO: handle more devices than wlan0
  echo INFO "DISABLING builtin wireless \(wlan0\)"
  rfkill block 0
}


function disable-dhcp-on-controlled-interfaces() {
  if grep "denyinterfaces wlan0 wlan1 eth1" /etc/dhcpcd.conf; then 
    echo INFO "SKIPPING disabling dhcp on eth1/wlan1 - already disabled"
  else
    echo INFO "DISABLING DHCP on wlan0 \(disabled internal wireless\) wlan1 \(external wireless\) and eth1 \(USB ethernet\)"
    builtin echo "denyinterfaces wlan0 wlan1 eth1" >> /etc/dhcpcd.conf
  fi
}


function enable-local-dns-server() {
  echo INFO "Setting up nameserver configuration"
  if grep "^name_servers=127.0.0.1" /etc/resolvconf.conf; then 
    echo 'name_servers=127.0.0.1' >> /etc/resolvconf.conf
  fi
}



function create-all-users() {
  echo INFO "Creating users"
  check-and-create-user jellyfin
  check-and-create-user audiobookshelf
  check-and-create-users www
}

function check-and-create-user() {
  id -u "$1" > /dev/null 2>&1 || useradd -s $(which nologin) -d "$DATA_DIR"/"$1" -r "$1"
}


function launch-docker-containers() {
  cd docker
  docker compose build
  docker compose pull
  docker compose up -d
}


main $@
