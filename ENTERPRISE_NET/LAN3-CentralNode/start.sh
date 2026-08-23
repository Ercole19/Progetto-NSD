#!/bin/bash
sleep 5

# --- RETE INTERNA (Verso i Runners) ---
ip addr add 10.30.1.10/24 dev eth0
ip link set eth0 up

# --- RETE ESTERNA (Internet via NAT) ---
ip link set eth1 up
dhclient eth1   # Richiede un IP dinamico e l'accesso a Internet al nodo NAT di GNS3

# Il gateway di default ora verrà impostato automaticamente da dhclient verso Internet.
# Dobbiamo però dire al sistema di usare eth0 per raggiungere i Runners (10.20.1.x)
ip route add 10.20.1.0/24 via 10.30.1.1 dev eth0

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