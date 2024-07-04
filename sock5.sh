#!/bin/bash

# Update the package list
sudo apt update

# Install dante-server
sudo apt -y install dante-server

# Create the danted.conf file
sudo bash -c 'cat > /etc/danted.conf <<EOF
logoutput: syslog

internal: eth0 port = 1080
external: eth0

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

# Restart the dante-server
sudo systemctl restart danted
sudo systemctl enable danted

# Open the port in the firewall
sudo ufw allow 1080/tcp
sudo ufw allow 1080/udp
