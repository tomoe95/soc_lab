#!/bin/bash

DATE=$(date)
LOGFILE=~/scripts/process-report.log
CPU_THRESHOLD=10.0

echo "==============================="
echo " Process Monitor Report"
echo " $DATE"
echo "==============================="


echo ""
echo "=== Memory Usage Summary ==="
free -h


echo ""
echo "=== Running Processes (Sort by CPU) ==="
ps aux --sort=-%cpu | head -n 15


echo ""
echo "=== Running Processes (Sort by Memory) ==="
ps aux --sort=-%mem | head -n 15


echo ""
echo "=== High CPU Processes (above $CPU_THRESHOLD%) ==="
HIGH=$(ps aux --sort=-%cpu | awk -v threshold="$CPU_THRESHOLD" 'NR>1 && $3+0 > threshold+0 {print $0}')

if [ -z "$HIGH" ]; then
    echo "No processes exceeding ${CPU_THRESHOLD}% CPU."
else
    echo "$HIGH"
fi

echo ""
echo "==============================="
echo "Report saved to: $LOGFILE"

{
    echo "==============================="
    echo " Process Monitor Report"
    echo " $DATE"
    echo "==============================="
    echo ""
    echo "=== Memory Usage Summary ==="
    free -h
    echo ""
    echo "=== Top 15 by CPU ==="
    ps aux --sort=-%cpu | head -n 15
    echo ""
    echo "=== Top 15 by Memory ==="
    ps aux --sort=-%mem | head -n 15
    echo ""
    echo "=== High CPU Processes (above $CPU_THRESHOLD%) ==="
    if [ -z "$HIGH" ]; then
        echo "None"
    else
        echo "$HIGH"
    fi
} >> "$LOGFILE"
