#!/bin/bash

# Update the package list
sudo apt update

# Install dante-server
sudo apt -y install dante-server

# Overwrite the danted.conf file with the updated configuration
sudo bash -c 'cat > /etc/danted.conf <<EOF
logoutput: syslog

# Listen on all interfaces for maximum compatibility
internal: 0.0.0.0 port = 1080
external: 0.0.0.0

method: username none

user.notprivileged: nobody
user.privileged: root
user.libwrap: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
}
EOF'

# Overwrite the systemd service file with updated configurations for Dante
sudo bash -c 'cat > /etc/systemd/system/danted.service <<EOF
[Unit]
Description=Dante SOCKS Proxy Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/danted -f /etc/danted.conf
ExecReload=/bin/kill -HUP \$MAINPID
Restart=always
RestartSec=10
StartLimitIntervalSec=0
LimitNOFILE=infinity
LimitNPROC=infinity

[Install]
WantedBy=multi-user.target
EOF'

# Reload the systemd daemon to apply any updates to the service configuration
sudo systemctl daemon-reload

# Enable and restart the danted service to ensure the latest configuration is applied
sudo systemctl enable danted
sudo systemctl restart danted

# Reset and open the firewall ports for the SOCKS5 proxy on both TCP and UDP protocols
sudo ufw delete allow 1080/tcp
sudo ufw delete allow 1080/udp
sudo ufw allow 1080/tcp
sudo ufw allow 1080/udp

echo "Dante SOCKS Proxy Server has been updated and is running. All configurations have been overridden."
