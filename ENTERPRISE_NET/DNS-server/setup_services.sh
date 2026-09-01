#!/bin/bash

# --- PARTE 1: DNSSEC ---
cd /etc/bind/

# Controlla se le chiavi esistono già. Se NON esistono, procedi.
if ! ls Knsdcourse.xyz.*.key 1> /dev/null 2>&1; then
    dnssec-keygen -a RSASHA256 -b 2048 -n ZONE nsdcourse.xyz
    dnssec-keygen -a RSASHA256 -b 4096 -n ZONE -f KSK nsdcourse.xyz
    cat Knsdcourse.xyz.*.key >> db.nsdcourse.xyz
fi

# Firma sempre la zona (sovrascrive il file .signed precedente)
dnssec-signzone -A -3 $(head -c 1000 /dev/urandom | sha1sum | cut -b 1-16) -N INCREMENT -o nsdcourse.xyz -t db.nsdcourse.xyz

# FIX: Usa 'service' invece di 'systemctl'
service named restart || service bind9 restart

# --- PARTE 2: APACHE ---
mkdir -p /var/www/nsdcourse
echo "<h1>Benvenuti nel web server NSD Course!</h1>" > /var/www/nsdcourse/index.html

# FIX: Creiamo il file di configurazione di Apache direttamente nella cartella giusta
cat << 'EOF' > /etc/apache2/sites-available/nsdcourse.conf
<VirtualHost *:80>
    ServerName www.nsdcourse.xyz
    ServerAlias ns1.nsdcourse.xyz
    DocumentRoot /var/www/nsdcourse
    <Directory /var/www/nsdcourse>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/nsdcourse_error.log
    CustomLog ${APACHE_LOG_DIR}/nsdcourse_access.log combined
</VirtualHost>
EOF

#Disabilita sito di default ubuntu
a2dissite 000-default.conf

# Attiva il sito e riavvia Apache
a2ensite nsdcourse.conf

# FIX: Usa 'service' invece di 'systemctl'
service apache2 restart
