#!/bin/bash
sleep 10

# --- RETE INTERNA ---
ip addr add 10.30.1.10/24 dev eth0
ip link set eth0 up
ip route add default via 10.30.1.1
echo "nameserver 198.51.100.66" > /etc/resolv.conf

# --- PREPARAZIONE CHIAVE PRIVATA ---
mkdir -p /root/.ssh
chmod 700 /root/.ssh

#Iniezione chiave privata
echo "LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUFNd0FBQUF0emMyZ3RaVwpReU5UVXhPUUFBQUNDQ1RZVWJvS2M0VWsvRFZmN2NQZm1qM0JUREtrRUlYazFLd2RvVDF2UnluQUFBQUpqT0svbVd6aXY1CmxnQUFBQXR6YzJndFpXUXlOVFV4T1FBQUFDQ0NUWVVib0tjNFVrL0RWZjdjUGZtajNCVERLa0VJWGsxS3dkb1QxdlJ5bkEKQUFBRUJTZVJsT3VDaGd6STBCVkZzWm5OSlZ5Z1pWRGcybUhIYlZBWjF0aW9BUUxJSk5oUnVncHpoU1Q4TlYvdHc5K2FQYwpGTU1xUVFoZVRVckIyaFBXOUhLY0FBQUFFWEp2YjNSQVEyVnVkSEpoYkMxT2IyUmxBUUlEQkE9PQotLS0tLUVORCBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0K" | base64 -d > /root/.ssh/id_ed25519
chmod 600 /root/.ssh/id_ed25519

# --- ACQUISIZIONE CHIAVI SERVER (AV1, AV2, AV3) ---
# Lista degli IP dei bersagli
TARGETS=("10.20.1.2" "10.20.1.3" "10.20.1.4")

for IP in "${TARGETS[@]}"; do
    echo "Attesa che il nodo $IP sia raggiungibile via SSH..."
    while true; do
        # ssh-keyscan prova a scaricare la chiave
        if ssh-keyscan -t ed25519 $IP >> /root/.ssh/known_hosts 2>/dev/null; then
            if grep -q "$IP" /root/.ssh/known_hosts; then
                echo "Chiave del nodo $IP acquisita con successo!"
                break
            fi
        fi
        sleep 2
    done
done
chmod 644 /root/.ssh/known_hosts

# --- FILE TEST ---
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /root/sample.bin

exec /bin/bash
