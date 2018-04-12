#!/usr/bin/env python
#
# house_hide.py - d.e.switzer 
#
# spew out fake wifi probes from IoT devices, cloud the area
#
# MACS USED / Source / Basic info:
## Thermostats
# 64:16:66:XX:XX:XX # Nest
# 18:B4:30:XX:XX:XX # Nest
# 44:61:32:XX:XX:XX # Ecobee
#
## Helpers
# 74:C2:46:XX:XX:XX # Amazon
# 68:54:FD:XX:XX:XX # Amazon Echo
# F4:F5:D8:XX:XX:XX # Google Home? (Check J.E.)
# 
## TV stuffs
# 00:04:4B:XX:XX:XX # Nvidia Shield
# B8:A1:75:XX:XX:XX # Roku
#
## Power Control
# 60:01:94:XX:XX:XX # Cheapo powerplugs
# A0:20:A6:XX:XX:XX # Cheapo Powerplugs
# 5C:CF:7F:XX:XX:XX # Cheapo Powerplugs
# 50:C7:BF:XX:XX:XX # TPlink POwer Plugs
# 
## Misc Control
# 00:17:88:XX:XX:XX # Phillips Hue Bridge
# B0:72:BF:XX:XX:XX # Wink

import random
macs = ['Nest#64:16:66', 'Nest#18:B4:30', 'Ecobee#44:61:32', 'Amazon Device#74:C2:46', 'Amazon Echo#68:54:FD', 'NVidia Shield#00:04:4B', 'Roku#B8:A1:75', 'Cheapo Powerplug#60:01:94', 'Cheapo Powerplug#A0:20:a6', 'Cheapo Powerplug#5C:CF:7F', 'TPLink Power Plug#50:C7:BF', 'Wink#B0:72:BF']
random.shuffle(macs)

import argparse,string, logging
logging.getLogger("scapy.runtime").setLevel(logging.ERROR)
from scapy.all import *
from random import randint
from time import sleep

__author__ = 'd.e.switzer'

def get_me_some_args():
    parser = argparse.ArgumentParser(
        description='Script sends out randomized 802.11 probe requests.')
    parser.add_argument(
        '-i', '--interface', type=str, help='Wifi interface', required=True)
    parser.add_argument(
        '-m', '--moninterface', type=str, help='Wifi monitor interface', required=False, default='mon0')
    parser.add_argument(
        '-c', '--channel', type=str, help='Channel #', required=False, default='11')
    parser.add_argument(
	'-s', '--ssid', type=str, help='SSID to broadcast probes for', required=False, default='Linksys')
    args = parser.parse_args()
    interface = args.interface
    moninterface = args.moninterface
    channel = args.channel
    SSID = args.ssid
    return interface,moninterface,channel,SSID

interface,moninterface,channel,SSID = get_me_some_args()

conf.iface = interface
int = interface
hw = interface
monint = moninterface
mac = ''

def randomssid(length):
        return ''.join(random.choice(string.lowercase) for i in range(length))

class Scapy80211():
    def  __init__(self,intf=int,ssid=SSID,source=mac,bssid='ff:ff:ff:ff:ff:ff'):
      self.rates = "\x03\x12\x96\x18\x24\x30\x48\x60"
      self.ssid    = ssid
      self.source  = source
      self.bssid   = bssid
      self.intf    = intf
      self.intfmon = 'mon0'
      conf.iface   = self.intfmon

      # create monitor interface using iw
      cmd = '/sbin/iw dev %s interface add %s type monitor >/dev/null 2>&1' \
        % (self.intf, self.intfmon)
      cmdintup = '/sbin/ifconfig %s up > /dev/null 2>&1' % (self.intfmon)
      try:
        os.system(cmd)
	os.system(cmdintup)
      except:
        raise

    def ProbeReq(self,count=1,ssid=SSID,dst='ff:ff:ff:ff:ff:ff'):
      if not ssid: ssid=self.ssid
      param =	Dot11ProbeReq()
      essid =	Dot11Elt(ID='SSID',info=ssid)
      rate1 =	"\x02\x04\x0b\x16"
      rate2 =	"\x82\x84\x0b\x16\x24\x30\x48\x6c"
      rate3 =	"\x03\x12\x96\x18\x24\x30\x48\x60"
      rate4 =	"\x82\x84\x8b\x96\x12\x24\x48\x6c"
      rates =	Dot11Elt(ID='Rates',info=rate4)
      dsset =	Dot11Elt(ID='DSset',info=chr(1))
      erpinfo = Dot11Elt(ID='ERPinfo',info='\x00')
      esrates =	Dot11Elt(ID='ESRates',info='\x0c\x18\x30\x60')
      tim =	Dot11Elt(ID='TIM',info='\x00\x01\x00\x00')

# Vendor specific extras.  Modeled after a Realtek device.  Add
# "/vendor" to the "pkt" definition below if you'd like to use them.
#
# These values are easy to find in WireShark under the "tagged options" for
# a wireless packet, and the variables below are named to be close or identical
# to how they are named in WireShark.
#
      uuidr = 		"\x10\x48\x00\x10\x52\x61\x6c\x69\x6e\x6b\x57\x50\x53\x2d\xac\x81\x12\xa1\xa3\x74"
      primarydevtype =	"\x10\x54\x00\x08\x00\x01\x00\x50\xf2\x04\x00\x01"
      rfbands = 	"\x10\x3c\x00\x01\x01"
      assocstate = 	"\x10\x02\x00\x02\x00\x00"
      configerror  =	"\x10\x09\x00\x02\x00\x00"
      devicepassid = 	"\x10\x12\x00\x02\x00\x00"
      devicename =   	"\x10\x11\x00\x0d\x52\x61\x6c\x69\x6e\x6b\x20\x43\x6c\x69\x65\x6e\x74"
      manufacturer = 	"\x10\x21\x00\x18\x52\x61\x6c\x69\x6e\x6b\x20\x54\x65\x63\x68\x6e\x6f\x6c\x6f\x67\x79\x2c\x20\x43\x6f\x72\x70\x2e"
      modelname = 	"\x10\x23\x00\x17\x52\x62\x6c\x6e\x6b\x20\x57\x69\x72\x65\x6c\x65\x73\x73\x20\x41\x64\x61\x70\x74\x65\x72\x10"
      modelnum = 	"\x10\x24\x00\x06\x52\x54\x32\x38\x30\x30"
      vendorextension = "\x10\x49\x00\x06\x00\x37\x2a\x00\x01\x20"
      hdcap = 		"\x2d\x1a\x6e\x01\x02\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
      hdcap2 =		"\x00\x00\x00\x00\x00\x00\x0e\x00\x00\x00\x00\x00"
      extendedcap = 	"\x7f\x01\x01"
      vendor = 		Dot11Elt(ID=221,len=167,info="\x00\x50\xf2\x04\x10\x4a" + 
           		"\x00\x01\x10\x10" + "\x3a\x00" + "\x01\x00\x10\x08" + "\x00\x02" + "\x22\x8c" + 
			uuidr + primarydevtype + rfbands + assocstate + configerror + devicepassid + devicename + 
			manufacturer + modelname + modelnum + vendorextension +hdcap + hdcap2 + extendedcap)

      pkt = RadioTap()\
        /Dot11(type=0,subtype=4,addr1=dst,addr2=self.source,addr3=self.bssid)\
        /param/essid/rates/esrates/tim

      print 'ProbeReq: SSID=[%s]|src=[%s]|count=%d' % (ssid,self.source,count)
      try:
        sendp(pkt,count=count,inter=0.1,verbose=0)
      except:
        raise

print "-------------------------------------------------"
print "   House Hide - send out fake home IoT probes"
print "-------------------------------------------------"
print "     .. hit control-C to stop the madness"
print "-------------------------------------------------"
print "Sending probe requests via " + hw + "..."
print "-------------------------------------------------"

while True:
	for toy in macs:
		data = toy.split("#")
		devicename = data[0]
		mac = data[1]
		yay = ":"
		lastpart = "%02x:%02x:%02x" % (random.randint(0, 255),random.randint(0, 255),random.randint(0, 255),)
		seq = (mac, lastpart)
		testmac = yay.join ( seq )
	#	SSID = randomssid(32)
		print "I'm a",devicename
		sdot11 = Scapy80211(intf=int,source=testmac,ssid=SSID)
		packet = sdot11.ProbeReq()
		sleepy=randint(1,4)
		print ".. sleeping", sleepy
		print " "
		sleep(sleepy)

