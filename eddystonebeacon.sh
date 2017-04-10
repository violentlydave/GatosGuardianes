#!/bin/bash
#
# - advertise out eddystone beacon
#
# https://github.com/google/eddystone/tree/master/eddystone-url
#sudo hcitool -i hci0 cmd 0x08 0x0008 17 02 01 06 03 03 aa fe 0f 16 aa fe 10 00 03 77 65 62 67 61 7a 65 72 08 00 00 00 00 00 00 00 00
#                                                                               XX [webgazerINhex        ] [08=.org]
#	AA= URL scheme, 
#		00 = http://www., 01 = https://www., 02 = http://, 03 = https://
# 	BB = addy in hex
#	CC = url encode
#		00=.com/, 01=.org/, 02=.edu/, 03=.net/, 04=.info/, 05=.biz/, 06=.gov/,
#		07=.com,  08=.org,  09=.edu,  10=.net,  11=.info,  12=.biz,  13=.gov,
#		
#	 		

INT="hci0"

# Bring the interface up
sudo hcitool $INT up

# Set bluetooth dev to "advertise /non-connectable"
sudo hciconfig $INT leadv 3

# Get yo beacon on!
# -> add code to sort out https/domain automatically

HOST="webgazer"
DOM=".org"
ENCODEDHOST=`echo $HOST | od -t x1 |grep 0000000 | sed "s/0000000 //g"`

#sudo hcitool -i hci0 cmd 0x08 0x0008 17 02 01 06 03 03 aa fe 0f 16 aa fe 10 00 03 77 65 62 67 61 7a 65 72 08 00 00 00 00 00 00 00 00
sudo hcitool -i $INT cmd 0x08 0x0008 17 02 01 06 03 03 aa fe 0f 16 aa fe 10 00 03 $ENCODEDHOST 08 00 00 00 00 00 00 00 00






