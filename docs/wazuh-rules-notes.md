# Wazuh Rules & Decoders Notes — Day 12

## Overview
Wazuh processes every log line through 3 phases before generating an alert.
Understanding this pipeline is essential for writing custom detection rules.

---

## The 3-Phase Log Processing Pipeline

```
Raw log line
     ↓
Phase 1: Pre-decoding  → extracts timestamp, hostname, program_name
     ↓
Phase 2: Decoding      → extracts structured fields (user, IP, command)
     ↓
Phase 3: Rule matching → matches fields against rules → generates alert
```

### Phase 1 — Pre-decoding (automatic)
Wazuh automatically extracts the standard syslog header from every log:
- `timestamp` — when the event happened
- `hostname` — which machine sent the log
- `program_name` — which program generated it

No configuration needed — this happens for every log line automatically.

### Phase 2 — Decoding (decoder files)
Decoder files parse the rest of the log line into structured fields using regex.

Location: `/var/ossec/ruleset/decoders/`

Example SSH decoder:
```xml
<decoder name="sshd">
  <program_name>sshd</program_name>
</decoder>

<decoder name="sshd-failed">
  <parent>sshd</parent>
  <regex>Failed \S+ for (\S+) from (\S+) port (\d+)</regex>
  <order>user, srcip, srcport</order>
</decoder>
```
- Parent decoder identifies the log source (`sshd`)
- Child decoder extracts specific fields using regex groups `()`
- `order` maps each regex group to a field name

### Phase 3 — Rule matching (rule files)
Rules match against the decoded fields and generate alerts.

Location: `/var/ossec/ruleset/rules/`

---

## Rule File Structure

```xml
<rule id="5710" level="5">
  <if_sid>5700</if_sid>
  <match>authentication failed</match>
  <description>SSH authentication failed</description>
  <mitre>
    <id>T1110</id>
  </mitre>
  <group>authentication_failed,pci_dss_10.2.4</group>
</rule>
```

| Field | Meaning |
|---|---|
| `id` | Unique rule number — must be unique across all rules |
| `level` | Severity 0–15 |
| `if_sid` | Only fires if parent rule ID also matched first (rule chaining) |
| `match` | Simple text pattern to find in the log line |
| `regex` | More powerful pattern matching using regular expressions |
| `description` | Human-readable explanation shown in the dashboard |
| `mitre` | ATT&CK technique ID this rule maps to |
| `group` | Categories used for filtering and compliance mapping |

---

## Rule Severity Levels

| Level | Severity | Meaning |
|---|---|---|
| 0–3 | Low | Informational — logged but no alert generated |
| 4–6 | Low-Medium | Notable — logged and shown in dashboard |
| 7–11 | Medium-High | Alert worthy — shown as alerts in dashboard |
| 12–15 | Critical | Active response triggered automatically |

---

## Rule Chaining (if_sid)

Rules build on each other in a parent → child hierarchy:

```
rule 5700  (parent)    "sshd message received"
  └── rule 5710        if_sid=5700 → "authentication failed"        level 5
        └── rule 5712  if_sid=5710 → "brute force (5+ failures)"   level 10
```

- Wazuh only checks child rules if the parent already matched
- Makes detection more efficient — doesn't check brute force rules on every log line
- Allows gradual escalation: single failure (level 5) → repeated failures (level 10)

---

## Level Escalation Pattern

This is how real SOC detection works:

| Event | Rule | Level | Action |
|---|---|---|---|
| Single failed login | 2501 | 5 | Log it, watch it |
| Repeated failures | 2502 | 10 | Alert! Possible brute force |
| Confirmed brute force | 5712 | 10 | Alert + MITRE T1110 tagged |

---

## Interesting Rules Found

### Rule 2501 — Authentication failure (level 5)
```xml
<rule id="2501" level="5">
  <match>FAILED LOGIN |authentication failure|</match>
  <match>Authentication failed for|invalid password for|</match>
  <match>LOGIN FAILURE|auth failure: |authentication error|</match>
  <description>syslog: User authentication failure.</description>
  <group>authentication_failed,pci_dss_10.2.4,gdpr_IV_35.7.d,hipaa_164.312.b</group>
</rule>
```
- Uses 6 different `<match>` patterns — covers SSH, PAM, FTP, and more with one rule
- Maps to 6 compliance frameworks automatically (PCI DSS, GDPR, HIPAA, NIST, TSC, GPG13)

### Rule 2502 — Repeated authentication failures (level 10)
```xml
<rule id="2502" level="10">
  <match>more authentication failures;|REPEATED login failures</match>
  <description>syslog: User missed the password more than one time</description>
  <mitre><id>T1110</id></mitre>
</rule>
```
- Escalates to level 10 when multiple failures detected
- MITRE T1110 (Brute Force) tagged directly

### Rule 5403 — First time sudo (level 4)
```xml
<rule id="5403" level="4">
  <description>First time user executed sudo.</description>
  <mitre><id>T1548.003</id></mitre>
</rule>
```
- Detects first-time sudo usage per user
- MITRE T1548.003 — Sudo and Sudo Caching (Privilege Escalation)
- `firedtimes: 1` — useful for detecting new privileged access on a server

---

## Compliance Mapping

Wazuh automatically maps alerts to compliance frameworks via the `<group>` tag.
No extra configuration needed — every tagged rule contributes to compliance reports.

| Framework | What it covers |
|---|---|
| `pci_dss_10.2.4` | PCI DSS — log failed login attempts |
| `gdpr_IV_35.7.d` | GDPR — monitor access to personal data |
| `hipaa_164.312.b` | HIPAA — audit controls for healthcare data |
| `nist_800_53_AC.7` | NIST — account lockout after failed attempts |
| `tsc_CC6.1` | SOC 2 — logical and physical access controls |

---

## Key Files & Locations

| Path | Purpose |
|---|---|
| `/var/ossec/ruleset/rules/` | All built-in detection rules |
| `/var/ossec/ruleset/decoders/` | All built-in log decoders |
| `/var/ossec/etc/rules/` | Your custom rules go here |
| `/var/ossec/etc/decoders/` | Your custom decoders go here |
| `/var/ossec/logs/ossec.log` | Manager log — check for rule errors |

---

## Testing Rules with wazuh-logtest

```bash
sudo /var/ossec/bin/wazuh-logtest
```

Paste a log line and press Enter twice. Shows all 3 phases:
- Phase 1: pre-decoded fields
- Phase 2: decoder name and extracted fields
- Phase 3: matched rule ID, level, description, MITRE tags

### Sample log lines to test

**SSH failed login:**
```
Jun 14 10:00:00 agentvm sshd[1234]: Failed password for root from 192.168.1.100 port 22 ssh2
```

**SSH successful login:**
```
Jun 14 10:00:00 agentvm sshd[1234]: Accepted password for admin from 192.168.1.100 port 22 ssh2
```

**New user created:**
```
Jun 14 10:00:00 agentvm useradd[1234]: new user: name=hacker, UID=1001, GID=1001
```

**Sudo usage:**
```
Jun 14 10:00:00 agentvm sudo: agent : TTY=pts/0 ; PWD=/home/agent ; USER=root ; COMMAND=/bin/bash
```

---

## MITRE ATT&CK Techniques in Wazuh Rules

| Technique | ID | Rules that detect it |
|---|---|---|
| Brute Force | T1110 | 2502, 5712, 5720 |
| Sudo and Sudo Caching | T1548.003 | 5403 |
| Privilege Escalation | T1548 | Multiple sudo/su rules |
| Credential Dumping | T1003 | auditd rules |

Search for any technique:
```bash
sudo grep -r "T1110" /var/ossec/ruleset/rules/ | head -10
```

---

## Notable Rule Files

| File | Covers |
|---|---|
| `0020-syslog_rules.xml` | General Linux system events |
| `0085-pam_rules.xml` | PAM authentication events |
| `0095-sshd_rules.xml` | SSH login, brute force, key usage |
| `0285-systemd_rules.xml` | Service start/stop events |
| `0315-apparmor_rules.xml` | AppArmor security denials |
| `0365-auditd_rules.xml` | Linux audit framework |
| `0475-suricata_rules.xml` | Network IDS alerts (Day 21) |
| `0850-audit_rules.xml` | Advanced audit events |
| `0900-firewall_rules.xml` | Firewall drop/accept events |

---

## Things I Learned
- Every log goes through 3 phases: pre-decode → decode → rule match
- Decoders turn unstructured text into structured fields using regex
- Rules use `if_sid` to chain — child rules only fire if parent matched
- Multiple `<match>` tags in one rule = OR logic (any one match triggers it)
- One rule can map to multiple compliance frameworks via the `<group>` tag
- `wazuh-logtest` is the fastest way to test if a rule fires correctly
- Level escalation (5 → 10) is how Wazuh distinguishes single events from attack patterns
- `firedtimes: 1` in wazuh-logtest means this is the first time this specific rule fired for this user/source
