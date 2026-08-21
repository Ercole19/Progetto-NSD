#!/bin/bash

# 1. Assegna l'IP alla scheda di rete e la accende
ip addr add 198.51.100.66/26 dev eth0
ip link set eth0 up

# 2. Imposta il gateway predefinito verso il GW200
ip route add default via 198.51.100.65

# 3. Lancia il tuo script per DNSSEC e Apache
/root/setup_services.sh

exec /bin/bash
