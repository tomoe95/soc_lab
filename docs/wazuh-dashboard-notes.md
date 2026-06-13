# Wazuh Dashboard Notes — Day 9

## Dashboard Navigation (Wazuh 4.12.0)

| Section | Location in Sidebar | What it shows |
|---|---|---|
| Security Events | Threat Intelligence → Threat Hunting | Timeline of all alerts fired |
| MITRE ATT&CK | Threat Intelligence → MITRE ATT&CK | Detected techniques mapped to the framework |
| Vulnerability Detection | Threat Intelligence → Vulnerability Detection | Known CVEs on monitored hosts |
| File Integrity Monitoring | Endpoint Security → File Integrity Monitoring | File changes detected on agents |
| Malware Detection | Endpoint Security → Malware Detection | Suspicious files flagged |
| Configuration Assessment | Endpoint Security → Configuration Assessment | Security hardening checks |
| Agents | Agents Management → Summary | All connected agents and their status |
| Rules | Server Management → Rules | All built-in and custom detection rules |

---

## Compliance Frameworks Available

Wazuh automatically maps alerts to these frameworks — found under **Security Operations**:

| Framework | What it covers |
|---|---|
| PCI DSS | Payment card industry security standard |
| GDPR | EU data protection regulation |
| HIPAA | US healthcare data protection |
| NIST 800-53 | US federal security controls framework |
| TSC | Trust Services Criteria (SOC 2) |

> 💡 In a real SOC job, compliance reporting is a major part of the work. Wazuh does this automatically by tagging each alert with relevant framework controls.

---

## Events Found on Day 9

| Timestamp | Agent | Rule ID | Level | Description |
|---|---|---|---|---|
| Jun 13, 2026 @ 13:01:01 | UbuntuVM | 502 | 3 | Wazuh manager started |

**Only 1 event — why:**
- No agents connected yet (manager only monitors itself at this stage)
- Rule 502 fires every time the Wazuh manager starts up
- More events will appear once agents are connected on Day 10

---

## Rule Severity Levels

| Level | Severity | Meaning | Example |
|---|---|---|---|
| 0–3 | Low | Informational, normal activity | Wazuh service started (502) |
| 4–7 | Medium | Suspicious but not critical | Multiple failed logins |
| 8–11 | High | Likely attack or serious issue | Brute force detected |
| 12–15 | Critical | Active attack or major breach | Rootkit detected |

---

## Interesting Rules Found in SSH Rule File
> Location: `/var/ossec/ruleset/rules/0095-sshd_rules.xml`

| Rule ID | Level | Description | MITRE Technique |
|---|---|---|---|
| 5710 | 5 | SSH authentication failed | T1110 - Brute Force |
| 5711 | 5 | SSH login attempt with invalid user | T1110 - Brute Force |
| 5712 | 10 | SSH brute force — multiple failures | T1110 - Brute Force |
| 5715 | 3 | SSH login successful | T1078 - Valid Accounts |
| 5720 | 10 | SSH login from unknown source | T1110 - Brute Force |

> 💡 **Rule 5712** is the one that will fire on Day 19 when you simulate a brute force attack — it triggers after multiple failed SSH attempts in a short time window.

---

## How a Wazuh Rule is Structured

```xml
<rule id="5710" level="5">
  <if_sid>5700</if_sid>
  <match>authentication failed</match>
  <description>SSH authentication failed</description>
  <mitre>
    <id>T1110</id>
  </mitre>
  <group>authentication_failed,pci_dss_10.2.4,pci_dss_10.2.5</group>
</rule>
```

| Field | Meaning |
|---|---|
| `id` | Unique rule identifier |
| `level` | Severity 0–15 |
| `if_sid` | Only trigger if parent rule also matched |
| `match` | Text pattern to look for in the log line |
| `description` | Human-readable explanation |
| `mitre` | ATT&CK technique ID |
| `group` | Categories and compliance frameworks this rule belongs to |

---

## ossec.log Health Check

```bash
sudo tail -n 30 /var/ossec/logs/ossec.log
```

**Result on Day 9:** No ERROR lines found — Wazuh installation is clean and healthy.

---

## Things I Learned
- Rule 502 fires every time the Wazuh manager starts — it's not an alert, just a health log
- Wazuh automatically maps every alert to compliance frameworks (NIST, PCI DSS, GDPR) — no extra config needed
- Rule levels go from 0 (info) to 15 (critical) — anything above 7 in a real SOC warrants investigation
- The `if_sid` field creates rule chains — child rules only fire if the parent rule matched first
- Rule 5712 (brute force) only fires after multiple failures — single failed logins are level 5, not critical
- An empty dashboard is normal without agents — Day 10 will change this significantly
