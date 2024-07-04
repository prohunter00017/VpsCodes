#!/bin/bash

# Update the package list
sudo apt update

# Install dante-server
sudo apt -y install dante-server

# Create the danted.conf file with both IPv4 and IPv6 support
sudo bash -c 'cat > /etc/danted.conf <<EOF
logoutput: syslog

# Listen on both IPv4 and IPv6 addresses
internal: 0.0.0.0 port = 1080
internal: ::0 port = 1080
external: 0.0.0.0
external: ::

method: username none

user.notprivileged: nobody
user.privileged: root
user.libwrap: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}

client pass {
    from: ::/0 to: ::/0
    log: connect disconnect error
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
}

pass {
    from: ::/0 to: ::/0
    protocol: tcp udp
}
EOF'

# Restart the dante-server
sudo systemctl restart danted
sudo systemctl enable danted

# Open the necessary ports in the firewall
sudo ufw allow 1080/tcp
sudo ufw allow 1080/udp

# Output the configured IPv4 and IPv6 addresses
echo "Dante SOCKS5 Proxy is configured to listen on the following addresses and port 1080:"
echo "IPv4 Address: 0.0.0.0:1080"
echo "IPv6 Address: ::0:1080"
