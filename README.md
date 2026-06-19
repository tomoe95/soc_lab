# 🛡️ Home SOC Lab

A personal Security Operations Center (SOC) built from scratch using free, open-source tools.
This project is a long-term learning environment for practicing real-world security monitoring,
detection engineering, incident response, and Linux administration.

---

## 🎯 Goals

- Build hands-on experience with a production-grade SIEM (Wazuh)
- Develop Linux administration skills through daily practice
- Write and maintain real detection rules mapped to MITRE ATT&CK
- Automate incident response with a SOAR platform (Shuffle)
- Build a portfolio of incident reports and detection engineering work
- Prepare for a cybersecurity internship

---

## 🗺️ Project Roadmap

| Level | Focus | Status |
|---|---|---|
| **Level 1** | Linux fundamentals + Wazuh SIEM setup | 🟡 In Progress |
| **Level 2** | Network detection (Suricata, Zeek) + threat simulation | ⬜ Not Started |
| **Level 3** | Incident response automation (Shuffle SOAR) | ⬜ Not Started |
| **Level 4** | Honeypot, threat intel (MISP), cloud (AWS) | ⬜ Not Started |
| **Extra 1** | Log analysis scripts (Python/Bash) | ⬜ Not Started |
| **Extra 2** | Vulnerability scanner lab (OpenVAS + Metasploitable) | ⬜ Not Started |
| **Extra 3** | Detection-as-code (GitHub Actions, rule linting) | ⬜ Not Started |

---

## ✅ Current Status — Day 12 of 120

### ✅ Week 1 Complete — Linux Fundamentals
- [x] **Day 1** — Installed VirtualBox, created Ubuntu 24.04 LTS ARM64 VM (4GB RAM, 50GB disk)
- [x] **Day 2** — Linux filesystem navigation, core commands, cheat sheet written
- [x] **Day 3** — Users, groups, permissions (`chmod`, `chown`, `/etc/passwd`, `/etc/group`)
- [x] **Day 4** — Bash scripting basics: wrote 3 scripts (uptime, process monitor, log analysis)
- [x] **Day 5** — SSH key-based auth, VirtualBox port forwarding, disabled password login
- [x] **Day 6** — systemd & service management (`systemctl`, `journalctl`, unit files)
- [x] **Day 7** — Week 1 review, VM snapshot (`week1-clean-baseline`), week summary written

### 🟡 Week 2 — Wazuh SIEM Setup
- [x] **Day 8** — Deployed Wazuh 4.12.0 all-in-one (indexer + manager + dashboard), dashboard accessible
- [x] **Day 9** — Explored Wazuh dashboard, rule files, compliance frameworks, ossec.log health check
- [x] **Day 10** — Created AgentVM, configured host-only network, registered and connected first Linux agent
- [x] **Day 11** — ~~Windows VM agent~~ Skipped — Mac disk at 100% capacity. Will revisit when storage is available.
- [x] **Day 12** — Studied Wazuh rules & decoders: 3-phase pipeline, rule chaining, MITRE mapping, wazuh-logtest

### Up Next — Week 3
- [ ] **Day 13** — Write first custom detection rule
- [ ] **Day 14** — Week 2 review & commit

---

## 🧰 Tools Used

| Tool | Purpose | Status |
|---|---|---|
| VirtualBox | VM hypervisor | ✅ Installed |
| Ubuntu 24.04 LTS (ARM64) — UbuntuVM | Wazuh manager OS | ✅ Running |
| Ubuntu 24.04 LTS (ARM64) — AgentVM | Wazuh agent OS | ✅ Running |
| OpenSSH | Remote access via SSH key-based auth | ✅ Configured |
| systemd | Service management & logging | ✅ Practiced |
| Wazuh 4.12.0 | SIEM — indexer, manager, dashboard | ✅ Installed |
| Wazuh Agent 4.12.0 | Agent on AgentVM — active & reporting | ✅ Connected |
| Windows VM | Wazuh Windows agent | ⏸️ Deferred — disk space |
| Suricata | Network IDS | ⬜ Pending |
| Zeek | Network analysis | ⬜ Pending |
| Shuffle | SOAR / playbook automation | ⬜ Pending |
| MISP | Threat intelligence platform | ⬜ Pending |
| T-Pot | Honeypot | ⬜ Pending |
| Atomic Red Team | Threat simulation | ⬜ Pending |
| OpenVAS / Greenbone | Vulnerability scanner | ⬜ Pending |

---

## 📁 Repository Structure

```
soc-lab/
├── docs/
│   ├── linux-commands.md               # Linux cheat sheet (nav, permissions, users, SSH, systemd)
│   ├── week1-summary.md                # Week 1 review — skills learned, challenges, next steps
│   ├── wazuh-install-notes.md          # Wazuh 4.12.0 installation steps, components, troubleshooting
│   ├── wazuh-dashboard-notes.md        # Wazuh dashboard overview, rule levels, SSH rules reference
│   ├── wazuh-agent-connection-guide.md # Step-by-step agent connection guide with troubleshooting
│   └── wazuh-rules-notes.md            # Rules & decoders: 3-phase pipeline, rule structure, MITRE mapping
├── scripts/
│   ├── uptime.sh                       # Prints system uptime with hostname and date
│   ├── processes.sh                    # Process monitor with CPU/memory sort, high CPU alert, log output
│   └── count-logs.sh                   # Log analyzer — line counts, errors, failed SSH logins
├── rules/                              # Custom Wazuh detection rules
├── playbooks/                          # Shuffle SOAR playbooks and runbooks
├── dashboards/                         # Dashboard screenshots and configs
├── portfolio/                          # Incident reports and writeups
└── README.md
```

---

## 🏗️ Lab Architecture

```
[ Mac Host ]
     │
     ├── SSH   (port 2222) ─────────────────────────┐
     ├── SSH   (port 2223) ─────────────────────┐   │
     ├── Wazuh (port 8443) ─────────────────────┼───┤
     │                                          │   ▼
     └── VirtualBox                             │  UbuntuVM (192.168.56.100)
           ├── Wazuh Indexer  (port 9200)       │   ├── Wazuh Manager
           ├── Wazuh Manager  (port 1514, 1515) │   ├── Wazuh Indexer
           ├── Wazuh Dashboard (port 443→8443)  │   └── Wazuh Dashboard
           │                                    │
           └── AgentVM (192.168.56.101) ────────┘
                 └── Wazuh Agent v4.12.0 (active)
```

---

## 📖 Daily Log

| Day | Task | Commit |
|---|---|---|
| 1 | Installed VirtualBox, created Ubuntu 24.04 LTS ARM64 VM | `chore: init ubuntu vm for soc lab environment` |
| 2 | Linux filesystem navigation and core commands cheat sheet | `docs: add linux filesystem navigation cheat sheet` |
| 3 | Users, groups, permissions — chmod, chown, /etc/passwd | `docs: add user permissions and chmod reference notes` |
| 4 | Bash scripting — uptime, process monitor, log analysis scripts | `feat(scripts): add system info, process monitor, and log analysis scripts` |
| 5 | SSH key-based auth, port forwarding, disabled password login | `chore: configure ssh key-based auth on ubuntu vm` |
| 6 | systemd service management, journalctl log analysis, unit files | `docs: add systemd and journalctl reference notes` |
| 7 | Week 1 review, VM snapshot, week summary written | `docs: add week 1 summary and lab baseline snapshot notes` |
| 8 | Deployed Wazuh 4.12.0 all-in-one, dashboard accessible via browser | `feat(siem): install wazuh manager and dashboard` |
| 9 | Explored Wazuh dashboard, rule files, compliance frameworks | `docs: add wazuh dashboard overview notes` |
| 10 | Created AgentVM, host-only network, registered first Linux agent | `feat(siem): register linux agent to wazuh manager` |
| 11 | Windows VM skipped — Mac disk full, removed VM to free storage | `docs: skip windows vm day 11 due to disk space constraints` |
| 12 | Wazuh rules & decoders: 3-phase pipeline, rule chaining, wazuh-logtest | `docs: add wazuh rules and decoders study notes` |

---

## 📚 Key Resources

- [Wazuh Documentation](https://documentation.wazuh.com)
- [Wazuh Quickstart](https://documentation.wazuh.com/current/quickstart.html)
- [Wazuh Rules Documentation](https://documentation.wazuh.com/current/user-manual/ruleset/ruleset-xml-syntax/rules.html)
- [Linux Journey](https://linuxjourney.com)
- [MITRE ATT&CK Framework](https://attack.mitre.org)
- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)
- [Shuffle SOAR](https://shuffler.io/docs)
- [T-Pot Honeypot](https://github.com/telekom-security/tpotce)
- [systemd Documentation](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
