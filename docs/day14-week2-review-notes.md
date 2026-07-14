# Day 14 — Week 2 Review & Wrap-up

## Overview
Final day of Week 2. Reviewed the full Wazuh SIEM setup, took clean snapshots of both
VMs, solved the daily VM restart/reconnection problem, and secured automation with
scoped passwordless sudo.

---

## What Was Done Today

### 1. VM Snapshots Taken
| VM | Snapshot Name | State Captured |
|---|---|---|
| UbuntuVM | `week2-wazuh-complete` | Manager + dashboard working, 5 custom rules tested |
| AgentVM | `week2-agent-complete` | Agent connected via host-only network, reporting events |

### 2. Verified Full Stack Health
```bash
sudo /var/ossec/bin/wazuh-control status
```
Confirmed all critical processes running: `wazuh-analysisd`, `wazuh-remoted`,
`wazuh-authd`, `wazuh-apid`.

```bash
sudo systemctl status wazuh-agent
```
Confirmed `active (running)` on AgentVM, dashboard shows `agentvm` as **Active**.

### 3. Solved the Daily Restart Problem
**Problem:** Every time both VMs were shut down and restarted, the Wazuh dashboard
showed the agent as disconnected.

**Root cause:** Not a persistence failure — netplan config was already correct and
IPs (`192.168.56.100` / `192.168.56.101`) were reapplying properly on boot. The real
issue was simply that services take time to fully start, and there was no easy way
to check/fix both VMs at once.

**Solution:** Built `start-lab.sh` — a single script that checks network + service
health on both VMs and restarts what's needed. See `docs/start-lab-script-guide.md`
for full details.

### 4. Fixed Passwordless Sudo for Automation
Running sudo commands over SSH non-interactively failed with:
```
sudo: a terminal is required to read the password
```

**Fix:** Added scoped NOPASSWD rules via `visudo` for only the specific commands the
automation script needs — not full sudo access.

**UbuntuVM** (`/etc/sudoers.d/wazuh-lab`):
```
tt ALL=(ALL) NOPASSWD: /var/ossec/bin/wazuh-control, /usr/sbin/netplan apply
```

**AgentVM** (`/etc/sudoers.d/wazuh-lab`):
```
agent ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart wazuh-agent, /usr/sbin/netplan apply
```

**Security reasoning:**
- Only 2 specific commands whitelisted per VM — not blanket `sudo`
- `netplan apply` restricted to the `apply` subcommand only, not arbitrary netplan actions
- No risk of command injection since these binaries take fixed, safe subcommands
- Real security boundary is SSH key protection, not this sudoers rule — this only
  matters if someone already has SSH access to the VM

---

## Week 2 Summary

See `docs/week2-summary.md` for the full week recap covering:
- Wazuh installation (Day 8)
- Dashboard exploration (Day 9)
- First agent connection (Day 10)
- Windows VM skip decision (Day 11)
- Rules & decoders study (Day 12)
- 5 custom detection rules (Day 13)
- This review day (Day 14)

---

## Things I Learned
- `visudo` validates syntax automatically before saving — safer than editing
  `/etc/sudoers` directly, which can lock you out if broken
- `EDITOR=nvim visudo` lets you use your preferred editor without changing system defaults
- Scoped NOPASSWD rules (specific binary + specific subcommand) are much safer than
  blanket `NOPASSWD: ALL`
- A home lab's real security boundary is SSH key protection — sudoers automation
  only matters to someone who already has that access
- Automation scripts are worth building even for a 2-VM lab — manually SSHing into
  multiple machines to check status daily doesn't scale, even at this small size
