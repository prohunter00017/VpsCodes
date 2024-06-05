#!/bin/bash

# Update the package lists
sudo apt update

# Install squid
sudo apt install -y squid

# Download the new squid.conf file
wget https://raw.githubusercontent.com/prohunter00017/VpsCodes/main/squid.conf

# Move the new squid.conf file to /etc/squid/, replacing the existing file
sudo mv squid.conf /etc/squid/

# Restart the squid service
sudo systemctl restart squid.service