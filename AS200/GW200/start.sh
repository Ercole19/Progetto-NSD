#!/bin/bash

# --- CONFIGURAZIONE INTERFACCE ---
# Aggiungo su eth0 (esterna) la sottorete /30 e su eth1 (interna/DMZ) la sottorete /26
ip addr add 198.51.100.6/30 dev eth0 
ip link set eth0 up
ip addr add 198.51.100.65/26 dev eth1
ip link set eth1 up

# --- CONFIGURAZIONE ROUTING ---
# Trasforma la macchina Linux in un router, abilitando l'inoltro di pacchetti fra schede di rete diverse
sysctl -w net.ipv4.ip_forward=1 

# Rotta di default: tutto il traffico sconosciuto (Internet) esce verso R201
ip route add default via 198.51.100.5
# Rotte statiche verso le reti VPN interne: il traffico è gestito dal concentratore VPN (.67)
ip route add 10.20.1.0/24 via 198.51.100.67
ip route add 10.20.2.0/24 via 198.51.100.67

# --- CONFIGURAZIONE FIREWALL (IPTABLES) ---
# Pulizia delle vecchie regole e impostazione della policy di base
iptables -F FORWARD
iptables -P FORWARD DROP # Deny-by-default: blocca tutto il traffico di transito non esplicitamente permesso

# Permette il traffico di ritorno per le connessioni generate dall'interno
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permette a tutti i dispositivi nella DMZ (eth1) di navigare verso Internet (eth0) liberamente
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

# -- REGOLE IN INGRESSO (Dal web verso la DMZ) --
# Consente le richieste esterne verso il Server DNS/Web (IP .66)
iptables -A FORWARD -i eth0 -d 198.51.100.66 -p udp --dport 53 -j ACCEPT # Porta 53 UDP per il DNS
iptables -A FORWARD -i eth0 -d 198.51.100.66 -p tcp --dport 80 -j ACCEPT # Porta 80 TCP per il traffico Web (HTTP)

# Consente le richieste esterne verso il Concentratore VPN (IP .67) per instaurare tunnel IPsec
iptables -A FORWARD -i eth0 -d 198.51.100.67 -p udp --dport 500 -j ACCEPT # Porta 500 UDP (IPsec IKE)
iptables -A FORWARD -i eth0 -d 198.51.100.67 -p udp --dport 4500 -j ACCEPT # Porta 4500 UDP (IPsec NAT-T)
iptables -A FORWARD -i eth0 -d 198.51.100.67 -p esp -j ACCEPT # Consente il protocollo ESP (traffico dati VPN criptato)


exec /bin/bash
