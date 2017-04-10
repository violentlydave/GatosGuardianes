#!/bin/bash
# - nmapme.sh - github.com/violentlydave
# ---- nmap -sP local net

INT=$1

if [[ $# -eq 0 ]] ; then
        echo ""
        echo " $0 - script to ping sweep local net."
        echo ""
        echo " usage:"
        echo " $0 wifi-interface-of-network-you-wanna-scan"
        echo "" 
	echo " ... no interface given, defaulting to wlan0. /24"
	INT="wlan0"
fi


NETWORKTOSCAN=`ifconfig $INT | grep broadcast | awk {'print $6'} | sed "s/255/0\/24/g"`

echo SCANNING $INT
nmap -sP -n $NETWORKTOSCAN
