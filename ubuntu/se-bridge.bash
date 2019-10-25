#!/bin/bash
# Execute as sudo
(( EUID != 0 )) && exec sudo -- "$0" "$@"
clear

read -rep $'!!! IMPORTANT !!!\n\nThis script will prepare SoftEther VPN for a local bridge setting. You MUST have previously installed the SoftEther VPN Server before using this script. Are you sure you want to continue? [y/N] ' response
case $response in
[yY][eE][sS]|[yY])

# Check if dnsmasq installed
# If not installed, install it
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' dnsmasq|grep "install ok installed")
echo  "Checking for dnsmasq: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "dnsmasq not installed. Installing now."
  sudo apt install -y dnsmasq
fi

# Check if dnsmasq installed
# Second pass, if not installed, exit with error
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' dnsmasq|grep "install ok installed")
echo  "Checking for dnsmasq: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "dnsmasq is still not installed. Possible problem with apt? Exiting."
  exit 1
fi

# Download pre-configured dnsmasq conf file
wget -O dnsmasq.conf https://raw.githubusercontent.com/AmurS/softether-autoinstall/master/dnsmasq.conf
rm /etc/dnsmasq.conf && mv dnsmasq.conf /etc/dnsmasq.conf

# Download pre-configured init script for SoftEther VPN
wget -O vpnserver-init-bridge https://raw.githubusercontent.com/AmurS/softether-autoinstall/master/vpnserver-init-bridge > /dev/null 2>&1
mv vpnserver-init-bridge /etc/init.d/vpnserver

# Write permissions for init script
chmod 755 /etc/init.d/vpnserver
printf "\nSystem daemon created. Registering changes...\n\n"

# Make SoftEther VPN a system service
update-rc.d vpnserver defaults > /dev/null 2>&1
printf "\nSoftEther VPN Server should now start as a system service from now on.\n\n"

# Start SE-VPN and dnsmasq server
systemctl start vpnserver
systemctl restart dnsmasq

printf "\nCleaning up...\n\n"
cd && rm -rf /tmp/softether-autoinstall > /dev/null 2>&1
systemctl is-active --quiet vpnserver && echo "Service vpnserver is running."
printf "\n${RED}!!! IMPORTANT !!!${NC}\n\nTo configure the server, use the SoftEther VPN Server Manager located here: http://bit.ly/2D30Wj8 or use ${RED}sudo /opt/vpnserver/vpncmd${NC}\n\n${RED}!!! UFW is not enabled with this script !!!${NC}\n\nTo see how to open ports for SoftEther VPN, please go here: http://bit.ly/2JdZPx6\n\nNeed help? Feel free to join the Discord server: https://icoexist.io/discord\n\n"
printf "\n${RED}!!! IMPORTANT !!!${NC}\n\nYou still need to add the local bridge using the SoftEther VPN Server Manager. It is important that after you add the local bridge, you restart both dnsmasq and the vpnserver!\nSee the tutorial here: http://bit.ly/2HoxlQO\n\n"
esac
