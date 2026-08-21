#!/bin/bash
ip addr add 203.0.113.6/30 dev eth0
ip link set eth0 up
ip link set eth1 up

# Avvia MACsec usando il file mka.conf
wpa_supplicant -i eth1 -D macsec_linux -c /etc/mka.conf -B
sleep 3
ip addr add 172.16.20.1/24 dev macsec0
ip link set macsec0 up

sysctl -w net.ipv4.ip_forward=1
ip route add default via 203.0.113.5

service ipsec restart
sleep 3
swanctl --load-all
# Eccezione: non nattare il traffico dalla LAN 2 alla LAN 1
iptables -t nat -A POSTROUTING -s 172.16.20.0/24 -d 10.10.1.0/24 -j ACCEPT

# Regola generale: natta tutto il resto che esce su Internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
exec /bin/bash
