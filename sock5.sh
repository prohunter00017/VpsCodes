#!/bin/bash

# Update the package list
sudo apt update

# Install dante-server
sudo apt -y install dante-server

# Create the danted.conf file with specific settings
sudo bash -c 'cat > /etc/danted.conf <<EOF
logoutput: syslog

# Listen on all interfaces
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

# Create or update the systemd service file to ensure Dante restarts automatically on failure
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

# Reload the systemd daemon to apply changes to the danted service
sudo systemctl daemon-reload

# Enable and start the danted service to ensure it starts on boot and restarts on failure
sudo systemctl enable danted
sudo systemctl restart danted

# Open the port in the firewall to allow external connections on port 1080
sudo ufw allow 1080/tcp
sudo ufw allow 1080/udp

echo "Dante SOCKS Proxy Server setup complete. The server will automatically restart on boot and on failure."
