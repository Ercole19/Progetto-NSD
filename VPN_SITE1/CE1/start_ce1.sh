#!/bin/bash
ip addr add 203.0.113.2/30 dev eth0
ip link set eth0 up
ip addr add 10.10.1.1/24 dev eth1
ip link set eth1 up
sysctl -w net.ipv4.ip_forward=1
ip route add default via 203.0.113.1

service ipsec restart
sleep 3
swanctl --load-all

# 1. Svuota la tabella POSTROUTING
iptables -t nat -F POSTROUTING

# 2. Inserisci l'eccezione corretta (Da LAN 1 a LAN 2)
iptables -t nat -A POSTROUTING -s 10.10.1.0/24 -d 172.16.20.0/24 -j ACCEPT

# 3. Rimetti la regola di navigazione Internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

exec /bin/bash
