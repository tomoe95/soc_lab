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

## ✅ Current Status — Day 2 of 120

### Completed
- [x] **Day 1** — Installed VirtualBox, created Ubuntu 24.04 LTS ARM64 VM (4GB RAM, 50GB disk)
- [x] **Day 2** — Learning Linux filesystem navigation and core commands

### In Progress
- [ ] **Day 2** — Writing Linux command cheat sheet (`docs/linux-commands.md`)

---

## 🧰 Tools Used

| Tool | Purpose | Status |
|---|---|---|
| VirtualBox | VM hypervisor | ✅ Installed |
| Ubuntu 24.04 LTS (ARM64) | Primary lab OS | ✅ Running |
| Wazuh | SIEM & agent management | ⬜ Pending |
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
│   └── linux-commands.md     # Linux command cheat sheet
├── rules/                    # Custom Wazuh detection rules
├── playbooks/                # Shuffle SOAR playbooks and runbooks
├── scripts/                  # Log analysis and automation scripts
├── dashboards/               # Dashboard screenshots and configs
├── portfolio/                # Incident reports and writeups
└── README.md
```

---

## 🏗️ Lab Architecture

```
[ Mac Host ]
     │
     └── VirtualBox
           ├── UbuntuVM (Wazuh Manager + Dashboard)   ← main SIEM
           ├── Windows VM (Wazuh Agent)                ← coming Day 11
           └── Metasploitable VM (vulnerable target)   ← coming Day 91
```

---

## 📖 Daily Log

| Day | Task | Commit |
|---|---|---|
| 1 | Installed VirtualBox, created Ubuntu 24.04 LTS VM | `chore: init ubuntu vm for soc lab environment` |
| 2 | Linux filesystem navigation and core commands | `docs: add linux filesystem navigation cheat sheet` |

---

## 📚 Key Resources

- [Wazuh Documentation](https://documentation.wazuh.com)
- [Linux Journey](https://linuxjourney.com)
- [MITRE ATT&CK Framework](https://attack.mitre.org)
- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)
- [Shuffle SOAR](https://shuffler.io/docs)
- [T-Pot Honeypot](https://github.com/telekom-security/tpotce)
