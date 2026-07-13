# Custom Detection Rules

## Rule 100010 — New User Account Created
- **File:** local_rules.xml
- **Level:** 7 (Medium-High)
- **Trigger:** Fires when `useradd` creates a new Linux user account
- **MITRE:** T1136.001 - Create Account: Local Account
- **Why it matters:** Attackers create new accounts to establish persistence
  after gaining initial access. This rule catches that activity in real time.
- **Tested:** Verified with wazuh-logtest and a real useradd command on AgentVM

---

## Rule 100011 — Custom SSH Brute Force Detection
- **File:** local_rules.xml
- **Level:** 10 (High)
- **Trigger:** 3+ SSH authentication failures within 60 seconds from the same source IP
- **Mechanism:** `if_matched_sid` chains off rule 5710 (SSH auth failed), using `frequency` + `timeframe` + `same_source_ip` to correlate repeated events
- **MITRE:** T1110 - Brute Force
- **Why it matters:** Faster detection than Wazuh's built-in rule 5712 (which needs 8 failures in 120s) — useful for catching fast automated attack tools
- **Tested:** Verified via wazuh-logtest and a real SSH brute force simulation from Mac terminal on 2026-07-12

---

## Rule 100012 — File Permission Changed to 777 (INCOMPLETE)
- **Status:** ⚠️ Not working yet — under investigation
- **Goal:** Detect when a file's permissions change to world-writable (777)
- **Attempted approaches:** `<field name="perm_after">`, `<regex>`, `<match>` — none successfully chained off rule 550
- **Confirmed working:** Rule 550 itself fires correctly with `perm_before`/`perm_after` fields populated
- **Hypothesis:** FIM-generated alerts (decoder: syscheck_integrity_changed) may not support if_sid chaining the same way syslog-based rules do — needs further research into Wazuh's internal FIM rule categories
- **Next steps:** Check Wazuh community forums/GitHub issues for FIM rule chaining, or try `if_group` instead of `if_sid`

---

## Rule 100013 — Web Shell / Suspicious File Extension Created
- **File:** local_rules.xml
- **Level:** 12 (Critical)
- **Trigger:** Fires when a new `.php` file is created in a monitored directory
- **Mechanism:** `if_sid` chains off rule 554 (file added to system), `<match>` checks for `.php` in the full log
- **MITRE:** T1505.003 - Server Software Component: Web Shell
- **Why it matters:** Attackers who compromise a web server often drop a web shell to maintain persistent access
- **Tested:** Verified with a real file creation on 2026-07-13 — fired correctly
- **Note:** Rule 554 (file added) chains successfully with if_sid, while rule 550 (file modified) did NOT chain correctly in this Wazuh version — worth investigating further (see Rule 100012 notes above)

---

## Rule 100014 — Successful Login After Brute Force (Correlation Rule)
- **File:** local_rules.xml
- **Level:** 15 (Maximum Severity)
- **Trigger:** Fires when a successful SSH login occurs from the same IP shortly after rule 100011 (brute force) fired
- **Mechanism:** `if_matched_sid` correlates against rule 100011 within Wazuh's default time window, `same_source_ip` ensures it's the same attacker
- **MITRE:** T1110 - Brute Force
- **Why it matters:** This is the worst-case scenario in a SOC — it means the attacker's brute force attempt likely succeeded. Requires immediate incident response.
- **Tested:** Verified via real SSH brute force simulation (3 failures) followed by successful login on 2026-07-13 — fired correctly at level 15

---

## Rule 100015 — Cron Job Persistence Detection
- **File:** local_rules.xml
- **Level:** 8 (Medium-High)
- **Trigger:** Fires when any user's crontab is modified (REPLACE action)
- **Mechanism:** `if_sid` chains off built-in rule 2832 (Crontab entry changed)
- **MITRE:** T1053.003 - Scheduled Task/Job: Cron
- **Why it matters:** Attackers commonly add cron jobs to maintain persistent access even after initial compromise is patched
- **Tested:** Verified with a real crontab modification containing a suspicious curl|bash pattern on 2026-07-13
- **Note:** $(user) shows empty — rule 2832 doesn't populate this field the same way sudo rules do; cosmetic issue only
