# start-lab.sh — Daily Lab Startup Script Guide

## Purpose
Automates the daily routine of checking and fixing network + Wazuh service health
across both VMs (UbuntuVM and AgentVM) after they've been shut down and restarted.

Instead of manually SSHing into each VM to check IPs and service status every day,
this script does it in one command from the Mac host.

---

## Location
```
~/soc-lab/scripts/start-lab.sh
```

## Full Script

```bash
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
```

---

## How It Works — Line by Line

### 1. UbuntuVM network check
```bash
ssh ubuntuvm "ip a show enp0s9 | grep 192.168.56.100 || sudo netplan apply"
```
- SSHes into UbuntuVM using the `ubuntuvm` alias from `~/.ssh/config`
- `ip a show enp0s9` — shows the host-only network interface
- `grep 192.168.56.100` — checks if the expected static IP is present
- `||` — if the grep finds nothing (IP missing), runs `sudo netplan apply` to
  reapply the network config as a fallback

### 2. UbuntuVM service check
```bash
ssh ubuntuvm "sudo /var/ossec/bin/wazuh-control status"
```
- Lists every Wazuh manager process and whether it's running
- Uses the passwordless sudo rule set up in `/etc/sudoers.d/wazuh-lab`

### 3. AgentVM network check
Same pattern as step 1, but checks for `192.168.56.101` (AgentVM's static IP)

### 4. AgentVM service restart
```bash
ssh agentvm "sudo systemctl restart wazuh-agent"
```
- Unlike UbuntuVM (which just checks status), the agent is **always restarted**
- This is intentional — restarting is cheap and guarantees a fresh connection
  attempt to the manager, fixing most "disconnected" states automatically

### 5. Final reminder
Prints the dashboard URL so you know where to check the result.

---

## Prerequisites for This Script to Work

| Requirement | Why |
|---|---|
| SSH config aliases (`ubuntuvm`, `agentvm`) set up in `~/.ssh/config` | Lets the script SSH without specifying port/user/key each time |
| SSH key-based auth configured (Day 5) | No password prompts breaking the script |
| Passwordless sudo for specific commands (Day 14) | Lets `wazuh-control` and `systemctl restart` run without a password over SSH |
| Both VMs must be running | Script doesn't start VMs — only fixes network/service state once they're up |

---

## How to Run It

```bash
cd ~/soc-lab/scripts
chmod +x start-lab.sh   # only needed once
./start-lab.sh
```

## Example Output (Healthy Run)

```
=== Checking UbuntuVM network ===
    inet 192.168.56.100/24 brd 192.168.56.255 scope global enp0s9
=== Checking UbuntuVM Wazuh services ===
wazuh-analysisd is running...
wazuh-remoted is running...
wazuh-authd is running...
wazuh-apid is running...
=== Checking AgentVM network ===
    inet 192.168.56.101/24 brd 192.168.56.255 scope global enp0s9
=== Restarting Wazuh agent ===
=== Done! Check dashboard at https://127.0.0.1:8443 ===
```

---

## Future Improvements to Consider
- Add a check that pings between VMs before restarting the agent, to catch
  network issues before wasting time on a service restart
- Add a `--verbose` flag to show full `wazuh-control status` output instead of
  just confirming it ran
- Add automatic VM boot via `VBoxManage startvm` so the whole lab starts with
  one command, including powering on both VMs
- Add a timestamp log so you can track how often reconnection issues occur over
  the 120-day project
