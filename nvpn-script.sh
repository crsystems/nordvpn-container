#!/bin/bash

# Initialize devices
mkdir /dev/net
mknod /dev/net/tun c 10 200

# Setup the needed routing entries
iptables -t nat -A POSTROUTING -s 172.17.0.1 -d 0.0.0.0/0 -j MASQUERADE
iptables -t filter -I INPUT -s 172.17.0.1/16 -d 172.17.0.2/16 -j ACCEPT

# Start nordvpn daemon
nordvpnd &

# Wait for the daemon to finish starting
sleep 10

# Login and connect
nordvpn login -u $NORDVPN_USER -p $NORDVPN_PASS
nordvpn connect $NORDVPN_SERVER_DNS

# Start logging
watch -n60 "nordvpn status" > /var/log/nordvpn-container.log 2>&1
