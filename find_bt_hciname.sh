#!/bin/bash
#
# http://github.com/violentlydave
#
# ZGF2aWQgRE9UIGUgRE9UIHN3aXR6ZXIgYVQgICBHRWVlZU1BSUx6IERBV1QgQ09NCg==
#
# real: l2ping -c 1 60:BE:B5:83:EE:1F
# l2ping -c 1 60:BE:B5:83:EE:1A; echo $?
# take last octet, add one (hex), try pinging
#     if ping works, that = bluetooth
#
#

# Comment out if you want quiet, uncomment for noise.
VERBOSE="1"

function log () {
    if [ ! -z $VERBOSE ]; then
        echo "$@"
    fi
}

if [[ $# -eq 0 ]] ; then
        echo ""
        echo " $0 - script to find bluetooth MAC addy via off-by-one"
        echo ""
        echo " usage:"
        echo " $0 WIFIMACADDRESS [optional HCI dev name, ex: hci1]"
        echo "" 
    exit 1
fi

HCIDEV=$2
if [ "$2" == "" ]; then HCIDEV="hci0"; fi


# did ya know BC hates HEX w/ lowercase?.. yeah I didn't either.
BLUETOOTHMAC=`echo $1 | tr '[:lower:]' '[:upper:]'`

# because math.  sloppy, sloppy math.
FIRSTFIVE=`echo $BLUETOOTHMAC | cut -d \: -f 1,2,3,4,5`
LAST=`echo $BLUETOOTHMAC | cut -d \: -f 6`
LASTDEC=`echo "ibase=16; $LAST" | bc`
DECPLUSONE=`expr $LASTDEC + 1`
DECMINUSONE=`expr $LASTDEC - 1`
HEXPLUSONE=`echo "obase=16; $DECPLUSONE" | bc`
HEXMINUSONE=`echo "obase=16; $DECMINUSONE" | bc`

TRIALMAC=$FIRSTFIVE":"$HEXPLUSONE

echo $BLUETOOTHMAC : $HEXPLUSONE
hcitool -i $HCIDEV name $TRIALMAC

TRIALMAC=$FIRSTFIVE":"$HEXMINUSONE
echo $BLUETOOTHMAC : $HEXMINUSONE
hcitool -i $HCIDEV name $TRIALMAC
