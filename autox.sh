#!/bin/bash
# autox
#   ..  sniff for X seconds for probes, use that list to
#	inquire device names via bluetoofs.
#		- des

DATE=`date +%Y%m%d-%H%M%S`
FILE="captures/$DATE.pcap"
OUTPUTFILE="captures/$DATE_probe_req_beacons.txt"
BTOUTPUTFILE="captures/$DATE_bluetooth_hcifo.txt"
INT="wlan1"
MONINT="wlan1mon"
BLUEINT="hci0"

TIMEINSECONDS=$1

INTCHECK=`ifconfig $INT | grep $INT`

if [ -z "$INTCHECK" ]; then
	echo " "
	echo "AutoX says: I need an external wifi interface.  Brah."
	exit 0
fi

echo "-----------------------------"
echo " .. autox"
echo "-----------------------------"
echo
echo "Sniff for probe reqs for X seconds,"
echo then try to figure out bluetooth interface
echo and get device name.
echo

if [[ $# -eq 0 ]] ; then
	TIMEINSECONDS="30"
	echo " "
        echo "$0 -- usage:  $0 TimeToRunInSeconds"
        echo "AutoX says:  ... defaulting to $TIMEINSECONDS seconds, brah."
	echo ""
fi

echo "-----------------------------"
echo Starting up monitor on $INT
echo "-----------------------------"
	ifconfig $INT
	airmon-ng start $INT 
echo "-----------------------------"
echo Capturing for $TIMEINSECONDS seconds to $FILE ...
echo "-----------------------------"
echo
	tcpdump -G $TIMEINSECONDS -W 1 -l -e -i $MONINT -s 256 -w $FILE \
		type mgt subtype probe-req

echo "-----------------------------"
echo Cleaning up $MONINT..
echo "-----------------------------"
echo
	airmon-ng stop $MONINT
echo "-----------------------------"
echo "Cleaning up list collected."
echo "-----------------------------"
echo
	tshark -r $FILE -Y 'wlan.fc.type_subtype eq 8 or wlan.fc.type_subtype eq 4 or wlan.fc.type_subtype eq 5' \
		-T fields -e wlan.fc -e wlan.sa_resolved -e wlan.sa -e wlan.da_resolved -e wlan.da -e wlan_mgt.ssid \
		| sort | uniq -c | sort -k 1 -n -r > $OUTPUTFILE 
echo
echo "-----------------------------"
echo "Checking for bluetooth names..."
echo "-----------------------------"
echo
if [ -n $`hcitool dev | awk {'print $1'} | grep -i hci` ]; then echo "Remove the WIFI interface and plug in a bluetooth int."; fi
until [ `hcitool dev | awk {'print $1'} | grep -i hci` ]; do sleep 1; done
echo " "
echo "Sweet, I have a bluetooth interface!"
echo "Checking for Bluetooth interfaces/names..."

	for DEVICE in `cat $OUTPUTFILE | awk {'print $4'} | sort | uniq`; do
		./find_bt_hciname.sh $DEVICE $BLUEINT >> $BTOUTPUTFILE
		done
