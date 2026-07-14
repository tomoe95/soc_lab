#!/bin/bash
echo "=== Checking UbuntuVM network ==="
ssh ubuntuvm "ip a show enp0s9 | grep 192.168.56.100 || sudo netplan apply"

echo "=== Checking UbuntuVM Wazuh services ==="
ssh ubuntuvm "sudo /var/ossec/bin/wazuh-control status"

echo "=== Checking AgentVM network ==="
ssh agentvm "ip a show enp0s9 | grep 192.168.56.101 || sudo netplan apply"

echo "=== Restarting Wazuh agent ==="
ssh agentvm "sudo systemctl restart wazuh-agent"

echo "=== Done! Check dashboard at https://127.0.0.1:8443 ==="
