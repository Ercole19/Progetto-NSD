#!/bin/bash

# --- PAUSA INIZIALE ---
# Attende 10 secondi per permettere al sistema operativo di completare l'avvio 
# delle schede di rete virtuali e dei servizi di base
sleep 10

# --- PREPARAZIONE INTERFACCIA FISICA ---
# Attiva l'interfaccia fisica eth1 senza assegnarle direttamente un indirizzo IP,
# poiché l'IP verrà legato all'interfaccia protetta MACsec
ip link set eth1 up

# --- SICUREZZA LAYER 2 (MACsec / IEEE 802.1AE) ---
# Avvia wpa_supplicant in background (-B) usando il driver macsec_linux e il file di configurazione /etc/mka.conf.
# Autentica l'host sul link di rete locale e crea l'interfaccia virtuale cifrata "macsec0"
wpa_supplicant -i eth1 -D macsec_linux -c /etc/mka.conf -B

# Pausa di 10 secondi per consentire la negoziazione MKA e la creazione dell'interfaccia macsec0
sleep 10

# --- CONFIGURAZIONE INDIRIZZO IP SULL'INTERFACCIA PROTEZIONE ---
# Assegna l'IP privato 172.16.20.10/24 all'interfaccia cifrata macsec0
ip addr add 172.16.20.10/24 dev macsec0
ip link set macsec0 up

# --- CONFIGURAZIONE ROUTING ---
# Imposta la rotta di default: qualsiasi pacchetto destinato all'esterno o ad altre LAN 
# viene inviato all'interfaccia macsec0 di CE2 (172.16.20.1)
ip route add default via 172.16.20.1

# --- CONFIGURAZIONE RISOLUZIONE NOMI (DNS) ---
# Definisce il server DNS primario centralizzato dell'infrastruttura
echo "nameserver 198.51.100.66" > /etc/resolv.conf

exec /bin/bash
