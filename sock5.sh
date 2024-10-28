#!/bin/bash

# Update the package list
sudo apt update

# Install dante-server if it's not already installed
if ! dpkg -l | grep -qw dante-server; then
    sudo apt -y install dante-server
fi

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
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
LimitNPROC=infinity

[Install]
WantedBy=multi-user.target
EOF'

# Reload the systemd daemon to apply any updates to the service configuration
sudo systemctl daemon-reload

# Enable and start the danted service to ensure it starts on boot and restarts on failure
sudo systemctl enable danted
sudo systemctl restart danted

# Open the port in the firewall to allow external connections on port 1080
sudo ufw allow 1080/tcp
sudo ufw allow 1080/udp

# Verify the status of the danted service
if systemctl is-active --quiet danted; then
    echo "Dante SOCKS Proxy Server setup complete and running."
else
    echo "Dante SOCKS Proxy Server failed to start. Checking logs..."
    sudo journalctl -u danted --no-pager -n 50
fi
