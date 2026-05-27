#!/bin/bash

TITLE="System Uptime"
DATE=$(date)
HOSTNAME=$(hostname)

echo "=== $TITLE ==="
echo "Host: $HOSTNAME"
echo "Date: $DATE"
uptime
