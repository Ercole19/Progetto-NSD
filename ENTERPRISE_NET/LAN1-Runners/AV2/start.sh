#!/bin/bash
sleep 5

# Assegna l'IP ad AV2
ip addr add 10.20.1.3/24 dev eth0
ip link set eth0 up

# Imposta l'eFW come gateway predefinito
ip route add default via 10.20.1.1


mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Incolla la stringa presa da chiave_master.pub qui sotto, mantenendo le virgolette
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJNhRugpzhST8NV/tw9+aPcFMMqQQheTUrB2hPW9HKc root@Central-Node" > /root/.ssh/authorized_keys

chmod 600 /root/.ssh/authorized_keys
service ssh restart

exec /bin/bash
