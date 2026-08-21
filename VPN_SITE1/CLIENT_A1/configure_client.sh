#!/bin/bash

# --- PAUSA INIZIALE ---
# Attende 10 secondi all'avvio del sistema per assicurarsi che i servizi di rete 
# del sistema operativo e l'interfaccia virtuale siano completamente pronti
sleep 10

# --- CONFIGURAZIONE INTERFACCIA E IP ---
# Assegna l'IP privato 10.10.1.10 con maschera /24 all'interfaccia di rete eth1.
# Questo IP fa parte della LAN 1 gestita dal router CE1 (10.10.1.1/24)
ip addr add 10.10.1.10/24 dev eth1

# Attiva l'interfaccia di rete (porta lo stato del link a UP)
ip link set eth1 up

# --- CONFIGURAZIONE ROUTING ---
# Imposta la rotta di default: qualsiasi pacchetto destinato a reti esterne o Internet
# deve essere inviato al gateway della LAN (ovvero al router CE1 con IP 10.10.1.1)
ip route add default via 10.10.1.1

# --- CONFIGURAZIONE DNS ---
# Sovrascrive il file /etc/resolv.conf impostando l'IP del server DNS primario (198.51.201.10).
# In questo modo l'host sarà in grado di tradurre i nomi di dominio (es. google.com) in indirizzi IP
echo "nameserver 198.51.100.66" > /etc/resolv.conf

# Termina lo script restituendo codice di successo (0)
exec /bin/bash
