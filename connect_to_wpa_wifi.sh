#!/bin/bash
#
# a script to connect a predefined wpa wifi network using wpa_supplicant
# this script assumes: 
#   a) you have already generated a psk from a passphrase using wpa_passphrase
#   b) your wpa_supplicant configuration file is in /etc/wpa_supplicant.conf
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
echo "Flushing route table"
# Doing this because old routing table had references to eth0 causing destination unreachable errors
ip route flush table main
netstat -nr

echo $short
echo "Setting wlan0 mode to managed.."
iwconfig wlan0 mode managed

echo $short
echo "Connecting to wifi with wpa_supplicant.."
wpa_supplicant -B -Dwext -iwlan0 -c/etc/wpa_supplicant.conf

echo $short
echo "Releasing old DHCP lease.."
dhclient -r -v wlan0 

echo $short
echo "Fetching IP through DHCP.."
dhclient -1 -v wlan0
echo "Exit code == $?"

if [ $? -ne 0 ]; then
  echo "Entering terminate"
  f_terminate
fi

echo $short
echo "Displaying ip configuration.."
ifconfig wlan0
sleep 3

echo $short
echo "Starting a ping to google DNS.."
ping 8.8.8.8
