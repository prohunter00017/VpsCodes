#!/bin/bash

# Update the package list
sudo apt update

# Install Squid, automatically selecting "yes" when prompted
sudo apt -y install squid

# Download the new squid.conf file
wget -O /etc/squid/squid.conf https://raw.githubusercontent.com/prohunter00017/VpsCodes/main/squid.conf

# Restart the Squid service
sudo systemctl restart squid.service
