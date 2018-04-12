#!/bin/bash
#
# Call someone, SAY SOMETHING.
# - david.e.switzer@gmail.com - mar 10 2017
# requires: asterisk festival flite
# 

# DEFAULT STUFFS
ASTERISKSOUNDS="/var/lib/asterisk/sounds/en"
ASTERISKCALLS="/var/spool/asterisk/outgoing"
IFS=$'\n'; DATE=$(date +%Y%m%d_%H%m%S)
YESTERDAY=$(date --date yesterday +%Y%m%d)
PHONE=$1; TRUNK=$2; MESSAGE=$3
NONE='\033[00m'; WHITE='\033[01;37m'; BOLD='\033[1m'; UNDERLINE='\033[4m'

if [[ $# -eq 0 ]] ; then
	echo -e "========================================================================="
	echo -e "${BOLD}${WHITE}$0${NONE}                                   - d.switzer"
	echo -e "========================================================================="
	echo -e ""
	echo -e " usage:"
	echo -e " $0 phone# trunkname words_in_quotes_if_more_than_one"; echo -e ""
	echo -e " ex:	$0 18136660666 TESTtrunk \"This is a test\""
	exit 0
fi

if [ ! -f `which text2wave` ]; then
    echo "missing: text2wav -- needed to create audio files - install festival and flite via apt-get"; exit 1
fi

if [ -f $ASTERISKSOUNDS/$YESTERDAY* ]; then
       	echo -e               "======================================"
	echo -e ${BOLD}${WHITE}Cleaning up sounds from yesterday...${NONE}
	rm $ASTERISKSOUNDS/$YESTERDAY*
fi

echo -e ==================
echo -e ${BOLD}${WHITE}Creating audio..${NONE}
echo -e ==================
echo "$3" | text2wave > $ASTERISKSOUNDS/$DATE.wav
lame -b 32 --resample 8 -a $ASTERISKSOUNDS/$DATE.wav $ASTERISKSOUNDS/$DATE.mp3
chown asterisk.asterisk $ASTERISKSOUNDS/*

echo -e ======================
echo -e ${BOLD}${WHITE}Creating call file..${NONE}
echo -e ======================
echo "Channel: SIP/$TRUNK/$PHONE" > /tmp/$DATE.call
echo "Application: Playback" >> /tmp/$DATE.call
echo "Data: $ASTERISKSOUNDS/$DATE" >> /tmp/$DATE.call

echo -e ======================
echo -e ${BOLD}${WHITE}Sending to ASTERISK..${NONE}
echo -e ======================
mv /tmp/$DATE.call $ASTERISKCALLS/ 

