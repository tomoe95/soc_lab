# Wazuh Agent Connection Guide

## Overview
This guide documents how to connect a Wazuh agent (on a separate VM) to the Wazuh manager.
Written after Day 10 — took multiple attempts due to NAT networking and version conflicts.

---

## Lab Setup
| Machine | Role | Host-only IP | NAT IP |
|---|---|---|---|
| UbuntuVM | Wazuh Manager | 192.168.56.100 | 10.0.2.15 |
| AgentVM | Wazuh Agent | 192.168.56.101 | 10.0.2.15 |

---

## Critical Rules (Learned the Hard Way)
> ⚠️ **NEVER install `wazuh-agent` on the same VM as `wazuh-manager`** — they share `/var/ossec/` and overwrite each other, breaking the manager.
> ⚠️ **Agent version must be equal to or lower than manager version** — installing a newer agent causes a version mismatch error.
> ⚠️ **VirtualBox NAT does not allow VM-to-VM communication** — you must use a Host-only network adapter for the two VMs to talk to each other.

---

## Part 1 — Network Setup (Host-only Adapter)

### Step 1 — Create a Host-only Network in VirtualBox
`VirtualBox` → `File` → `Host Network Manager` → `Create`

This creates a virtual network interface that allows VMs to communicate with each other and the Mac host.

### Step 2 — Add Host-only Adapter to both VMs
For each VM (UbuntuVM and AgentVM):
- Shut down the VM
- `Settings` → `Network` → `Adapter 2` → ✅ Enable
- Attached to: `Host-only Network`
- Start the VM

### Step 3 — Bring up the host-only interface on both VMs
```bash
sudo ip link set enp0s9 up
```
- `ip link set` — controls network interface state
- `enp0s9` — the name of the second network adapter (host-only)
- `up` — activates the interface so it can send/receive traffic

### Step 4 — Assign static IPs on the host-only interface

**On UbuntuVM (manager):**
```bash
sudo ip addr add 192.168.56.100/24 dev enp0s9
```

**On AgentVM:**
```bash
sudo ip addr add 192.168.56.101/24 dev enp0s9
```

- `ip addr add` — assigns an IP address to a network interface
- `192.168.56.x/24` — the IP address with subnet mask `/24` (255.255.255.0)
- `dev enp0s9` — specifies which interface to assign it to

### Step 5 — Make the IP persistent across reboots
Edit the netplan config on **each VM**:
```bash
sudo nvim /etc/netplan/50-cloud-init.yaml
```

**On UbuntuVM** add:
```yaml
network:
  version: 2
  ethernets:
    enp0s8:
      dhcp4: true
    enp0s9:
      addresses:
        - 192.168.56.100/24
```

**On AgentVM** add:
```yaml
network:
  version: 2
  ethernets:
    enp0s8:
      dhcp4: true
    enp0s9:
      addresses:
        - 192.168.56.101/24
```

Apply the changes:
```bash
sudo netplan apply
```
- `netplan apply` — reads the YAML config and applies the network settings permanently

### Step 6 — Verify connectivity between VMs
```bash
ping -c 3 192.168.56.100   # run on AgentVM to ping the manager
```
- `ping -c 3` — sends 3 ICMP packets to test if the host is reachable
- You should see `3 packets transmitted, 3 received, 0% packet loss`

---

## Part 2 — Install Wazuh Agent on AgentVM

### Step 1 — Add the Wazuh repository
```bash
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && sudo chmod 644 /usr/share/keyrings/wazuh.gpg
```
- `curl -s` — downloads the Wazuh GPG signing key silently
- `gpg --import` — imports the key so apt can verify Wazuh packages are genuine
- `chmod 644` — sets correct permissions on the keyring file

```bash
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list
```
- Adds the Wazuh package repository to apt's source list
- `tee` — writes the output to the file (requires sudo for system directories)

### Step 2 — Install the agent (same version as manager)
```bash
sudo apt update
sudo apt install wazuh-agent=4.12.0-1 -y
```
- Always specify the exact version with `=4.12.0-1` to match the manager
- Installing a newer version than the manager causes a connection refusal

### Step 3 — Configure the agent to point to the manager
```bash
sudo nvim /var/ossec/etc/ossec.conf
```

Find and change:
```xml
<address>MANAGER_IP</address>
```
To:
```xml
<address>192.168.56.100</address>
```
- This tells the agent where to find the manager (use the host-only IP, not NAT IP)

---

## Part 3 — Register the Agent on the Manager

> Auto-enrollment sometimes fails due to SSL issues. Use manual registration instead.

### Step 1 — On UbuntuVM, open the agent manager tool
```bash
sudo /var/ossec/bin/manage_agents
```
- `manage_agents` — Wazuh's CLI tool for adding, removing, and listing agents

### Step 2 — Add a new agent
- Press `A` to add
- Enter name: `agentvm`
- Enter IP: `any`
- Press `Enter` to confirm the auto-assigned ID (e.g. `001`)
- Press `Q` to quit

### Step 3 — Extract the agent key
```bash
sudo /var/ossec/bin/manage_agents -e 001
```
- `-e 001` — exports the authentication key for agent ID 001
- Copy the entire long key string that appears

### Step 4 — On AgentVM, import the key
```bash
sudo /var/ossec/bin/manage_agents
```
- Press `I` to import
- Paste the key copied from the manager
- Press `Enter` and confirm with `Y`
- Press `Q` to quit

---

## Part 4 — Start the Agent and Verify

### Step 1 — Enable and start the agent
```bash
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```
- `daemon-reload` — reloads systemd after config changes
- `enable` — makes the agent start automatically on every boot
- `start` — starts the agent immediately

### Step 2 — Check agent logs
```bash
sudo tail -f /var/ossec/logs/ossec.log
```
- `tail -f` — watches the log file in real time
- Look for: `Connected to the server ([192.168.56.100]:1514/tcp)`
- Look for: `Agent is now online`

### Step 3 — Verify in the Wazuh dashboard
Open: `https://127.0.0.1:8443`
Go to: `Agents Management` → `Summary`
The agent should appear as **Active** with a green dot.

---

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `Unable to connect to enrollment service at port 1515` | Manager not reachable | Check host-only network is set up correctly |
| `Agent version must be lower or equal to manager version` | Agent is newer than manager | Reinstall agent with exact version: `apt install wazuh-agent=4.12.0-1` |
| `Duplicate agent name` | Agent already registered on manager | Remove old entry: `manage_agents` → `R` → agent ID |
| `Invalid server address: MANAGER_IP` | ossec.conf not updated after reinstall | Edit `/var/ossec/etc/ossec.conf` and set correct IP |
| IP lost after reboot | Static IP not saved to netplan | Add `enp0s9` block to `/etc/netplan/50-cloud-init.yaml` |
| `Transport endpoint is not connected` | Manager not listening on host-only interface | Verify manager is running: `sudo /var/ossec/bin/wazuh-control status` |

---

## Verify Manager is Healthy
```bash
sudo /var/ossec/bin/wazuh-control status
```
A healthy manager shows these processes running:
- `wazuh-analysisd` — main detection engine
- `wazuh-remoted` — receives agent connections on port 1514
- `wazuh-authd` — handles agent enrollment on port 1515
- `wazuh-apid` — REST API on port 55000

If you only see `wazuh-agentd` — the manager was replaced by an agent package. Restore from snapshot.

---

## Key Ports
| Port | Service | Purpose |
|---|---|---|
| 1514 | wazuh-remoted | Agent communication (logs, alerts) |
| 1515 | wazuh-authd | Agent enrollment and key exchange |
| 55000 | wazuh-apid | REST API for dashboard and external tools |
| 443 | wazuh-dashboard | Web UI (forwarded to host port 8443) |
