#!/bin/bash
FILE_TO_SCAN=$1

echo "=== REPORT CLAMAV ==="
echo "Analisi del file: $FILE_TO_SCAN"

# Esegue la scansione disabilitando il riepilogo per avere un output pulito
clamscan "$FILE_TO_SCAN"

if [ $? -eq 0 ]; then
    echo "Stato: NESSUNA MINACCIA RILEVATA"
fi
