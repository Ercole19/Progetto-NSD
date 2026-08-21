#!/bin/bash
# Specifica che questo è uno script eseguibile in Bash

# --- CONFIGURAZIONE INTERFACCE ---
# Assegna l'indirizzo IP all'interfaccia eth0 (collegata alla LAN1, fungendo da ponte verso l'eFW)
ip addr add 10.20.1.254/24 dev eth0
# Accende l'interfaccia eth0
ip link set eth0 up

# Assegna l'indirizzo IP all'interfaccia eth1 (questo IP diventerà il Gateway per tutti i PC della LAN2)
ip addr add 10.20.2.1/24 dev eth1
# Accende l'interfaccia eth1
ip link set eth1 up

# --- ROUTING DI BASE ---
# Abilita l'IP forwarding nel kernel, autorizzando il sistema operativo a far transitare i pacchetti tra le due schede di rete
sysctl -w net.ipv4.ip_forward=1

# Imposta la rotta predefinita: tutto il traffico destinato all'esterno della LAN2 viene inviato all'Enterprise Firewall (eFW) all'IP 10.20.1.1
ip route add default via 10.20.1.1

# --- INIZIO REGOLE FIREWALL (IPTABLES) ---
# Elimina (flush) tutte le regole preesistenti nella catena FORWARD per partire da zero
iptables -F FORWARD

# Imposta la policy di default (Regola d'oro): blocca automaticamente tutto il traffico in transito che non corrisponde a regole specifiche
iptables -P FORWARD DROP

# REGOLA IN USCITA: Consente ai dispositivi della LAN2 (sottorete 10.20.2.0/24) collegati su eth1 di comunicare verso l'esterno uscendo da eth0
iptables -A FORWARD -i eth1 -o eth0 -s 10.20.2.0/24 -j ACCEPT

# REGOLA IN ENTRATA (Stateful): Consente al traffico di rientrare nella LAN2 (da eth0 verso eth1) SOLO SE è la risposta a una connessione legittima precedentemente avviata dall'interno
iptables -A FORWARD -i eth0 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT

exec /bin/bash
