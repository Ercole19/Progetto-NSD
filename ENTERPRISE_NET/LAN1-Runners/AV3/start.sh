#!/bin/bash
sleep 10

# --- RETE ---
ip addr add 10.20.1.4/24 dev eth0
ip link set eth0 up
ip route add default via 10.20.1.1

# --- PREPARAZIONE SSH ---
mkdir -p /root/.ssh
chmod 700 /root/.ssh

echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJNhRugpzhST8NV/tw9+aPcFMMqQQheTUrB2hPW9HKc root@Central-Node" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Sicurezza: Disabilita le password
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

service ssh restart

exec /bin/bash
