#!/bin/bash

# --- CONFIGURAZIONE INTERFACCE ---
# Assegno l'IP pubblico/WAN all'interfaccia eth0 per la connessione verso R201 (sottorete /30: .1 e .2)
ip addr add 198.51.100.2/30 dev eth0
ip link set eth0 up

# Assegno l'IP privato/LAN all'interfaccia eth1, che fa da gateway per la rete locale LAN3 (10.30.1.0/24)
ip addr add 10.30.1.1/24 dev eth1
ip link set eth1 up

# --- ROUTING E NAT ---
# Abilito il forwarding IP nel kernel Linux per permettere il transito dei pacchetti tra eth0 ed eth1
sysctl -w net.ipv4.ip_forward=1

# Imposto la rotta di default: tutto il traffico non locale/Internet viene inviato a R201 (198.51.100.1)
ip route add default via 198.51.100.1


# Maschero il traffico della LAN 3 con l'IP pubblico di R202 per permettere la comunicazione con l'esterno
# Svuota e riscrivi con l'eccezione per il tunnel verso LAN1
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -s 10.30.1.0/24 -d 10.20.1.0/24 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# --- AVVIO SERVIZIO VPN (strongSwan) ---
# Riavvio il demone IPsec per assicurarmi che parta da uno stato pulito
service ipsec restart

# Attendo 5 secondi per dare il tempo al demone BGP/IPsec (charon) di inizializzarsi completamente
sleep 5

# Carica in memoria tutte le configurazioni e le chiavi segrete definite nei file di swanctl
swanctl --load-all

exec /bin/bash
