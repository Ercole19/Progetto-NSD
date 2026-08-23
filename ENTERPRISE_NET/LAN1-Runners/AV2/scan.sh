#!/bin/bash
FILE_TO_SCAN=$1

echo "=== REPORT CAPA (ANALISI COMPORTAMENTALE) ==="
echo "Analisi delle capacità del file: $FILE_TO_SCAN"

# Aggiungiamo -r /opt/capa-rules per indicare la cartella delle regole
capa -r /opt/capa-rules -q "$FILE_TO_SCAN"

if [ $? -eq 0 ]; then
    echo "[*] Analisi statica completata."
else
    echo "[-] File non supportato o errore nell'analisi."
fi