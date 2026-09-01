#!/bin/bash
# Specifica che questo è uno script eseguibile in Bash

# --- CONFIGURAZIONE INTERFACCE ---
# Assegna l'indirizzo IP esterno (verso GW200) all'interfaccia eth0 e la accende
ip addr add 198.51.100.67/26 dev eth0
ip link set eth0 up

# Assegna l'indirizzo IP interno (Gateway per la LAN1 - Runners) a eth1 e la accende
ip addr add 10.20.1.1/24 dev eth1
ip link set eth1 up

# --- ROUTING DI BASE ---
# Abilita la funzione di routing nel kernel Linux (trasforma il server in un vero router)
sysctl -w net.ipv4.ip_forward=1

# Rotta di default: invia tutto il traffico Internet/sconosciuto al gateway GW200
ip route add default via 198.51.100.65

# Rotta interna: per raggiungere la LAN2, invia i pacchetti al firewall interno iFW (10.20.1.254)
ip route add 10.20.2.0/24 via 10.20.1.254

# --- INIZIO REGOLE FIREWALL (IPTABLES) ---
# Svuota tutte le vecchie regole di transito (FORWARD)
iptables -F FORWARD
# Imposta la policy di base: blocca tutto il traffico in transito di default (Regola d'oro)
iptables -P FORWARD DROP

# Consente il traffico di ritorno per le connessioni in uscita già stabilite e autorizzate
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Autorizza i PC della LAN1 (Runners) a comunicare verso la LAN3 (Central Node)
iptables -A FORWARD -i eth1 -s 10.20.1.0/24 -d 10.30.1.0/24 -j ACCEPT
# Autorizza la comunicazione inversa: dalla LAN3 (Central Node) verso la LAN1 (Runners)
iptables -A FORWARD -s 10.30.1.0/24 -d 10.20.1.0/24 -j ACCEPT



# Blocca esplicitamente qualsiasi altro tentativo di comunicazione in uscita dalla LAN1 (Runners isolati)
iptables -A FORWARD -i eth1 -s 10.20.1.0/24 -j DROP

# Autorizza tutto il traffico proveniente dalla LAN2 (che ha regole separate gestite da iFW)
iptables -A FORWARD -s 10.20.2.0/24 -j ACCEPT

# Applica il NAT (Masquerade) per permettere ai dispositivi della LAN2 di navigare su Internet
iptables -t nat -A POSTROUTING -s 10.20.2.0/24 -o eth0 -j MASQUERADE
# --- FINE REGOLE FIREWALL ---

# --- AVVIO VPN ---
# Riavvia il servizio IPsec per partire da una situazione pulita
service ipsec restart
# Attende 5 secondi per permettere al servizio di avviarsi in background
sleep 5
# Carica la configurazione del tunnel VPN (dal file swanctl.conf) in memoria
swanctl --load-all

# Termina lo script con successo
exec /bin/bash
