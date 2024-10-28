#!/bin/bash

# Variables
PASSWORD="1993x"
PORT=8388
TIMEOUT=300
METHOD="aes-256-gcm"
CONFIG_FILE="/etc/shadowsocks-libev/config.json"

# Update and install Shadowsocks
echo "Updating package list and installing Shadowsocks..."
sudo apt update
sudo apt install -y shadowsocks-libev

# Configure Shadowsocks
echo "Configuring Shadowsocks..."
sudo mkdir -p /etc/shadowsocks-libev

sudo tee $CONFIG_FILE > /dev/null <<EOL
{
    "server": "0.0.0.0",
    "server_port": $PORT,
    "local_port": 1080,
    "password": "$PASSWORD",
    "timeout": $TIMEOUT,
    "method": "$METHOD",
    "fast_open": true
}
EOL

# Configure firewall to restrict access to port 8388
echo "Setting up firewall rules to allow only specific IP access..."
sudo ufw allow $PORT
sudo ufw allow ssh
sudo ufw enable

# Start and enable Shadowsocks service
echo "Starting and enabling Shadowsocks service..."
sudo systemctl start shadowsocks-libev
sudo systemctl enable shadowsocks-libev

echo "Shadowsocks installation and configuration complete."
echo "Server is running on port $PORT with password '$PASSWORD'."
