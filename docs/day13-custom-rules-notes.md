# Day 13 — Custom Detection Rules

## Overview
Wrote and tested 5 custom Wazuh detection rules covering account creation, brute force
detection, web shell detection, attack correlation, and persistence detection.
One rule (777 permission detection) could not be resolved despite extensive debugging —
documented below as a known issue.

---

## ✅ Rule 100010 — New User Account Created

```xml
<rule id="100010" level="7">
  <if_sid>5902</if_sid>
  <match>new user</match>
  <description>New user account created: $(user)</description>
  <mitre>
    <id>T1136.001</id>
  </mitre>
  <group>user_management,pci_dss_10.2.5,gdpr_IV_35.7.d,</group>
</rule>
```

- **Trigger:** Fires when `useradd` creates a new Linux user
- **Status:** ✅ Working — tested and confirmed in dashboard
- **MITRE:** T1136.001 - Create Account: Local Account

---

## ✅ Rule 100011 — SSH Brute Force Detection

```xml
<rule id="100011" level="10" frequency="3" timeframe="60">
  <if_matched_sid>5710</if_matched_sid>
  <same_source_ip />
  <description>Custom: Possible SSH brute force - 3+ failures in 60s from same IP</description>
  <mitre>
    <id>T1110</id>
  </mitre>
  <group>authentication_failures,custom_brute_force,</group>
</rule>
```

- **Trigger:** 3+ SSH authentication failures within 60 seconds from the same source IP
- **Status:** ✅ Working — tested via real SSH brute force simulation from Mac terminal
- **MITRE:** T1110 - Brute Force
- **Note:** More sensitive than Wazuh's built-in rule 5712 (which needs 8 failures in 120s)

---

## ⚠️ Rule 100012 — File Permission Changed to 777 (UNRESOLVED)

```xml
<rule id="100012" level="12">
  <if_sid>550</if_sid>
  <match>to 'rwxrwxrwx'</match>
  <description>Critical: File permissions changed to world-writable (777) - $(file)</description>
  <mitre>
    <id>T1222.002</id>
  </mitre>
  <group>file_permission,custom_777_detection,pci_dss_11.5,</group>
</rule>
```

- **Goal:** Detect when a file's permissions change to world-writable (777)
- **Status:** ❌ Not working — could not get this to fire despite multiple approaches

### What was confirmed working:
- File Integrity Monitoring (FIM) itself works correctly
- Rule **550** ("Integrity checksum changed") fires reliably on permission changes
- The JSON alert for rule 550 correctly shows `perm_before` and `perm_after` fields:
  ```json
  "syscheck":{"perm_before":"rw-rw-r--","perm_after":"rwxrwxrwx", ...}
  ```

### Approaches attempted (all failed to chain a child rule off 550):
1. **`<field name="perm_after">rwxrwxrwx</field>`** — no match, even though the field
   exists exactly as named in the JSON. Checked built-in rules and found no example of
   Wazuh using `<field>` to match syscheck-specific fields (only used for JSON-namespaced
   fields like `aws.eventName`).
2. **`<regex>to 'rwxrwxrwx'</regex>`** — no match. Regex may require anchored matching
   from the start of `full_log`, which would explain failure since the target text is
   mid-string.
3. **`<match>to 'rwxrwxrwx'</match>`** — no match either, even though `<match>` is
   documented as a substring search and should not require anchoring.

### Verified NOT the cause:
- XML syntax was validated with `wazuh-analysisd -t` — no errors
- Rule file was confirmed loaded (no `local_rules.xml` critical errors after fixes)
- Timing was ruled out — tested with 15-20 second delays between actions and manager restarts
- Confirmed testing against genuinely new files each time (avoided stale file/cache issues)

### Working comparison — Rule 100013 (Web Shell Detection):
The nearly identical pattern **did** work when chaining off rule **554** ("File added to
the system") instead of 550 ("modified"):
```xml
<rule id="100013" level="12">
  <if_sid>554</if_sid>
  <match>.php</match>
  <description>Critical: Suspicious web shell file created - $(file)</description>
  ...
</rule>
```
This fired correctly on the first attempt.

### Hypothesis
Rule 550 (`syscheck_entry_modified` / decoder `syscheck_integrity_changed`) may not
support `if_sid` chaining the same way rule 554 (`syscheck_entry_added` / decoder
`syscheck_new_entry`) does — possibly due to how the "modified" event category is
internally categorized or grouped in Wazuh 4.12.0's FIM engine. This may be a
version-specific quirk or an undocumented limitation with the "modified" FIM alert type.

### Next steps to try later
- Check Wazuh GitHub issues / community forums for FIM rule chaining limitations
- Try `if_group` instead of `if_sid`
- Try matching on `changed_attributes` field explicitly
- Try a completely fresh rule ID range in case of ID collision with an internal rule
- Test on a newer Wazuh version to see if this is version-specific

---

## ✅ Rule 100013 — Web Shell / Suspicious File Created

```xml
<rule id="100013" level="12">
  <if_sid>554</if_sid>
  <match>.php</match>
  <description>Critical: Suspicious web shell file created - $(file)</description>
  <mitre>
    <id>T1505.003</id>
  </mitre>
  <group>web_shell,custom_detection,pci_dss_11.5,</group>
</rule>
```

- **Trigger:** Fires when a new `.php` file is created in a monitored directory
- **Status:** ✅ Working — fired correctly on first test
- **MITRE:** T1505.003 - Server Software Component: Web Shell
- **Key learning:** Chaining off rule 554 (file *added*) works reliably, unlike rule 550
  (file *modified*) — see Rule 100012 notes above

---

## ✅ Rule 100014 — Successful Login After Brute Force (Correlation Rule)

```xml
<rule id="100014" level="15">
  <if_matched_sid>100011</if_matched_sid>
  <same_source_ip />
  <description>CRITICAL: Successful SSH login after brute force pattern detected - possible compromise!</description>
  <mitre>
    <id>T1110</id>
  </mitre>
  <group>authentication_success,brute_force_success,pci_dss_10.2.4,</group>
</rule>
```

- **Trigger:** Fires when any event occurs from the same IP shortly after rule 100011
  (brute force) fired — in practice, this catches the successful login itself
- **Status:** ✅ Working — fired correctly on first test, reaching level 15 (max severity)
- **MITRE:** T1110 - Brute Force
- **Why it matters:** This is the worst-case SOC scenario — brute force that succeeded
- **Test performed:** 3 failed SSH logins followed immediately by 1 successful login,
  both from the same source IP within the correlation time window

---

## ✅ Rule 100015 — Cron Job Persistence Detection

```xml
<rule id="100015" level="8">
  <if_sid>2832</if_sid>
  <match>REPLACE</match>
  <description>Cron job added or modified by user $(user) - possible persistence</description>
  <mitre>
    <id>T1053.003</id>
  </mitre>
  <group>persistence,cron,pci_dss_10.2.5,</group>
</rule>
```

- **Trigger:** Fires when any user's crontab is modified
- **Status:** ✅ Working — fired correctly on first test
- **MITRE:** T1053.003 - Scheduled Task/Job: Cron
- **Why it matters:** Attackers commonly add cron jobs to maintain persistent access
- **Cosmetic issue:** `$(user)` displays empty since rule 2832 doesn't populate a `user`
  field the way sudo-based rules do — functional but not fully labeled

---

## Summary Table

| Rule ID | Level | Detects | MITRE | Status |
|---|---|---|---|---|
| 100010 | 7 | New user account created | T1136.001 | ✅ Working |
| 100011 | 10 | SSH brute force (3+ fails/60s) | T1110 | ✅ Working |
| 100012 | 12 | File permission → 777 | T1222.002 | ❌ Unresolved |
| 100013 | 12 | Web shell file created | T1505.003 | ✅ Working |
| 100014 | 15 | Login success after brute force | T1110 | ✅ Working |
| 100015 | 8 | Cron job persistence | T1053.003 | ✅ Working |

---

## Debugging Techniques Learned Today

| Technique | Command | Purpose |
|---|---|---|
| Validate rule syntax without restart | `sudo /var/ossec/bin/wazuh-analysisd -t` | Catches XML errors instantly |
| Check for critical rule load failures | `grep -i "critical\|error loading" /var/ossec/logs/ossec.log` | Confirms rules file actually loaded |
| Parse alerts reliably by rule ID | `python3 -c "import json; ..."` reading `alerts.json` | Avoids false positives from `grep` matching command text itself |
| Inspect raw internal fields | `grep -A 2 '"id":"XXX"' alerts.json` | Shows exact field names/casing for `<field>` matching |
| Test decoder/rule parsing | `sudo /var/ossec/bin/wazuh-logtest` | Confirms decoder match and phase-by-phase rule evaluation (works for syslog-based logs, NOT FIM-generated alerts) |
| Find existing rules for a technology | `sudo grep -B5 -A10 "keyword" /var/ossec/ruleset/rules/*.xml` | Discover correct parent rule IDs before writing custom chains |

---

## Key Lessons Learned

- **`grep` on log files can produce false positives** — searching for a rule ID number
  will also match your own terminal commands if they contain that number as text.
  Always parse JSON properly with Python for reliable verification.
- **Not all parent rules support `if_sid` chaining equally** — FIM "modified" events
  (rule 550) behaved differently than "added" events (rule 554) in this Wazuh version.
- **`wazuh-logtest` doesn't work for FIM-generated alerts** — it's designed for testing
  decoders against raw syslog-style text. FIM alerts are generated internally by
  `wazuh-syscheckd` and bypass the normal decoder pipeline entirely.
- **`<field>` tag matching works well for JSON-namespaced integrations** (like AWS
  CloudTrail) but may not reliably match internal FIM-specific fields like `perm_after`.
- **Restart timing matters** — always allow 15-20 seconds after `wazuh-control restart`
  before triggering test events, and confirm the manager is fully up before testing.
- **Correlation rules (`if_matched_sid`) are powerful** — they let you detect
  multi-stage attack patterns (like brute force → successful login) that single-event
  rules can never catch.
- **Real debugging is iterative** — spent significant time on rule 100012 without
  success, but that same debugging process (checking JSON structure, testing simpler
  versions, comparing against a working example) is exactly what real detection
  engineers do daily. Documenting the failure with full reasoning is as valuable as a
  successful rule.
