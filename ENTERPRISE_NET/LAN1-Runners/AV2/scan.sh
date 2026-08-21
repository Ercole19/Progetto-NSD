#!/bin/bash
FILE_TO_SCAN=$1

echo "=== REPORT RKHUNTER ==="
echo "Analisi di sistema innescata dal file: $FILE_TO_SCAN"
echo "Avvio ricerca rootkit ed exploit locali..."

# Esegue un check del sistema non interattivo, stampando solo i warning
rkhunter --check --skip-keypress --report-warnings-only

echo "Scansione di sistema completata."
