#!/bin/bash
#
# a script to initialize the wlan0 interface, set promiscuous mode, connect to an open ap, and start a ping
#
##############################################################################################################

# Catch process termination
trap f_terminate SIGHUP SIGINT SIGTERM

# Global variables
short='========================================'

BLUE='\033[1;34m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ESSID=$1

if [[ $# -eq 0 ]] ; then
    echo -e "${RED}${short}${NC}"
    echo -e "${RED}Syntax: connect_to_open_wifi_promisc.sh <essid>${NC}"
    echo -e "${RED}${short}${NC}"
    exit 0
fi

f_terminate(){

  echo $short
  echo "Terminating..."
  echo "Bringing wlan0 down.."
  ifconfig wlan0 down

  exit
}

echo $short
echo "Stopping network manager.."
service network-manager stop
echo $short
echo "Killing dhclient and wpa_supplicant.."
killall dhclient
killall wpa_supplicant

echo $short
echo "Bringing wlan0 down.."
ifconfig wlan0 down
echo $short
echo "Putting wlan0 into promiscuous.."
ifconfig wlan0 promisc
echo $short
echo "Bringing wlan0 up.."
ifconfig wlan0 up 
echo $short
echo "Setting wlan0 mode to managed and essid to ${ESSID}.."
iwconfig wlan0 mode managed essid $ESSID
echo $short
echo "Fetching IP through DHCP.."
dhclient -v wlan0

echo $short
echo "Starting a ping to google DNS.."
ping 8.8.8.8

