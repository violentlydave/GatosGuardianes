DATE=`date +%Y%m%d-%H%M%S`
FILE="captures/$DATE.pcap"
INT="wlan1"

echo -----------------------------
echo Starting up monitor on $INT
echo -----------------------------
	ifconfig wlan1
	airmon-ng start wlan1 
echo -----------------------------
echo Capturing to $FILE ...
echo -----------------------------
echo
	tcpdump -l -e -i wlan1mon -s 256 -w $FILE type mgt subtype probe-req
echo -----------------------------
echo Cleaning up...
echo -----------------------------
echo
	airmon-ng stop wlan1mon 
