#!/bin/bash
# Attende qualche secondo l'inizializzazione del nodo
sleep 5

# Assegna l'IP al client nella LAN2
ip addr add 10.20.2.10/24 dev eth0
ip link set eth0 up

# Imposta l'iFW (10.20.2.1) come gateway predefinito
ip route add default via 10.20.2.1

# Imposta il server DNS interno (situato nella DMZ)
echo "nameserver 198.51.100.66" > /etc/resolv.conf

exec /bin/bash
