#!/bin/bash
sleep 5

# --- RETE INTERNA (Verso R202 e il resto dell'infrastruttura) ---
ip addr add 10.30.1.10/24 dev eth0
ip link set eth0 up

# (La configurazione di eth1 e dhclient è stata rimossa perché non c'è più il nodo NAT)

# --- CONFIGURAZIONE ROUTING E DNS ---
# R202 (10.30.1.1) diventa il gateway assoluto per andare ovunque (Runners, DMZ, Internet)
ip route add default via 10.30.1.1

# Imposta il DNS aziendale situato nella DMZ
echo "nameserver 198.51.100.66" > /etc/resolv.conf

# --- PREPARAZIONE SSH E TEST ---
# Crea le cartelle e i permessi
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Decodifica la chiave dalla singola riga per evitare errori di formattazione
echo "LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUFNd0FBQUF0emMyZ3RaVwpReU5UVXhPUUFBQUNDQ1RZVWJvS2M0VWsvRFZmN2NQZm1qM0JUREtrRUlYazFLd2RvVDF2UnluQUFBQUpqT0svbVd6aXY1CmxnQUFBQXR6YzJndFpXUXlOVFV4T1FBQUFDQ0NUWVVib0tjNFVrL0RWZjdjUGZtajNCVERLa0VJWGsxS3dkb1QxdlJ5bkEKQUFBRUJTZVJsT3VDaGd6STBCVkZzWm5OSlZ5Z1pWRGcybUhIYlZBWjF0aW9BUUxJSk5oUnVncHpoU1Q4TlYvdHc5K2FQYwpGTU1xUVFoZVRVckIyaFBXOUhLY0FBQUFFWEp2YjNSQVEyVnVkSEpoYkMxT2IyUmxBUUlEQkE9PQotLS0tLUVORCBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0K" | base64 -d > /root/.ssh/id_rsa

chmod 600 /root/.ssh/id_rsa
echo "StrictHostKeyChecking no" > /root/.ssh/config

# Prepara il file di test
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /root/sample.bin

exec /bin/bash