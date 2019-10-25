#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
(( EUID != 0 )) && exec sudo -- "$0" "$@"
clear
read -p "$(echo -e 'This will COMPLETELY remove SoftEther VPN from your server.\nThis will only work if you used the softether-install script.\n\nAre you sure you want to contiunue? [y/N]\n\b')" response
case $response in
[yY][eE][sS]|[yY])
printf "\nPurging SE-VPN processes and/or files.\n"
cd ~
rm se-autoinstall > /dev/null 2>&1
rm softether* > /dev/null 2>&1
service vpnserver stop > /dev/null 2>&1
update-rc.d vpnserver remove > /dev/null 2>&1
rm /etc/init.d/vpnserver > /dev/null 2>&1
rm -rf /usr/local/vpnserver > /dev/null 2>&1
rm -rf vpn* > /dev/null 2>&1
rm -rf /opt/vpnserver > /dev/null 2>&1
printf "\nDone. Do you want to download and run the softether-autoinstall script? (e.g. doing an upgrade?) [y/N]\n\b"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
  wget -O se-install https://raw.githubusercontent.com/AmurS/softether-autoinstall/master/ubuntu/16.04/se-install-ubuntu.bash && chmod 770 se-install && ./se-install
else
  printf "\nAlright, we're done here!\n\b"
fi
esac
