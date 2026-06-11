# Wazuh Installation Notes — Day 8

## Overview
Installed Wazuh 4.12.0 all-in-one (indexer + manager + dashboard) on Ubuntu 24.04 LTS ARM64 VM.

---

## Environment
| Item | Value |
|---|---|
| Host | Apple Silicon Mac (ARM64) |
| VM | Ubuntu 24.04 LTS ARM64 on VirtualBox |
| RAM | 3.8GB total, 3.4GB available |
| Wazuh Version | 4.12.0 |
| VM IP | 10.0.2.15 |

---

## Installation Steps

### 1. Update the system
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Download the installer and config
```bash
curl -sO https://packages.wazuh.com/4.12/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.12/config.yml
```

### 3. Edit config.yml — set all IPs to VM's IP
```bash
nvim config.yml
```
Set all three node IPs to `10.0.2.15`:
```yaml
nodes:
  indexer:
    - name: node-1
      ip: 10.0.2.15
  server:
    - name: wazuh-1
      ip: 10.0.2.15
  dashboard:
    - name: dashboard
      ip: 10.0.2.15
```

### 4. Generate SSL certificates
```bash
sudo bash wazuh-install.sh --generate-config-files
```

### 5. Install Wazuh indexer
```bash
sudo bash wazuh-install.sh --wazuh-indexer node-1
```

### 6. Start the cluster
```bash
sudo bash wazuh-install.sh --start-cluster
```

### 7. Install Wazuh server (manager)
```bash
sudo bash wazuh-install.sh --wazuh-server wazuh-1
```

### 8. Install Wazuh dashboard
```bash
sudo bash wazuh-install.sh --wazuh-dashboard dashboard
```
> ⚠️ **Typo to avoid:** `dashborad` causes an error — must be `dashboard`

### 9. Verify all services are running
```bash
sudo systemctl status wazuh-manager
sudo systemctl status wazuh-indexer
sudo systemctl status wazuh-dashboard
```
All three should show `active (running)`.

---

## Accessing the Dashboard

Since VirtualBox uses NAT, direct browser access is blocked.
Added a port forwarding rule to reach the dashboard from Mac:

| Name | Protocol | Host IP | Host Port | Guest IP | Guest Port |
|---|---|---|---|---|---|
| wazuh | TCP | 127.0.0.1 | 8443 | 10.0.2.15 | 443 |

Access via Mac browser:
```
https://127.0.0.1:8443
```
- Accept the browser security warning (self-signed certificate — normal for local lab)
- Login: `admin` / `<password from install output>`

> 💡 To retrieve the password if lost:
> ```bash
> sudo tar -O -xvf wazuh-install-files.tar ./wazuh-passwords.txt
> ```

---

## Wazuh Components

| Component | Purpose | Port |
|---|---|---|
| Wazuh Indexer | Stores and indexes all alert data (OpenSearch) | 9200 |
| Wazuh Manager | Receives logs from agents, runs detection rules | 1514, 1515 |
| Wazuh Dashboard | Web UI for viewing alerts and managing agents | 443 |

---

## Challenges & Fixes

| Problem | Cause | Fix |
|---|---|---|
| `No certificate for node dashborad` | Typo in command — `dashborad` instead of `dashboard` | Re-run with correct spelling |
| Dashboard not loading immediately | Wazuh takes 2–3 min to fully start after boot | Wait and refresh |

---

## Things I Learned
- Wazuh is made of 3 components — indexer, manager, and dashboard — all need to be installed separately
- The node names in `config.yml` must exactly match the names passed to the installer flags
- Self-signed SSL certificates cause browser warnings on local installs — this is normal and safe in a lab
- `free -h` shows RAM — always check `available` column, not `free`
- Port forwarding in VirtualBox NAT is needed for every new service that exposes a web port
