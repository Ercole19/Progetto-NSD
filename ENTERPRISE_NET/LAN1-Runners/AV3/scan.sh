#!/bin/bash
FILE_TO_SCAN=$1

echo "=== REPORT YARA ==="
echo "Analisi del file: $FILE_TO_SCAN"

# Esegue YARA puntando al file delle regole creato nell'immagine
MATCHES=$(yara /opt/yara_rules/*.yar "$FILE_TO_SCAN")

if [ -n "$MATCHES" ]; then
    echo "[!] MINACCIA RILEVATA DALLA REGOLA YARA:"
    echo "$MATCHES"
else
    echo "Stato: PULITO"
fi
