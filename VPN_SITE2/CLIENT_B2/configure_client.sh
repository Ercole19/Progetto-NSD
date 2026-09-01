#! /bin/bash
sleep 10

# 1. Accende l'interfaccia fisica senza IP (il "tubo" per i dati cifrati)
ip link set eth1 up

# 2. Avvia la negoziazione MACsec
wpa_supplicant -i eth1 -D macsec_linux -c /etc/mka.conf -B

# Pausa per permettere la creazione dell'interfaccia sicura
sleep 10

# 3. Assegna il nuovo indirizzo IP (172.16.20.11) all'interfaccia macsec0
ip addr add 172.16.20.11/24 dev macsec0
ip link set macsec0 up

# 4. Imposta il Gateway predefinito (Punta sempre all'IP del router CE2)
ip route add default via 172.16.20.1

# 5. Imposta il server DNS
echo "nameserver 198.51.100.66" > /etc/resolv.conf

exec /bin/bash
