# Day 18 — File Integrity Monitoring (FIM) Setup

## Overview
Built a comprehensive FIM configuration monitoring a realistic config directory,
testing the full file lifecycle: creation, content modification, ownership change,
and deletion. Explored why FIM is a core SOC/compliance control.

---

## FIM Configuration Options Reference

| Setting | Scope | What it does |
|---|---|---|
| `<frequency>43200</frequency>` | Global | Full scheduled scan every 12 hours (in seconds) |
| `<scan_on_start>yes</scan_on_start>` | Global | Run a full scan immediately when Wazuh starts |
| `<alert_new_files>yes</alert_new_files>` | Global | Alert when brand new files appear, not just modifications |
| `<auto_ignore frequency="10" timeframe="3600">no</auto_ignore>` | Global | Don't suppress alerts even if a file changes 10+ times/hour |
| `realtime="yes"` | Per-directory | Watch continuously instead of waiting for scheduled scans |
| `report_changes="yes"` | Per-directory | Show a diff of actual file content changes |
| `check_perm="yes"` | Per-directory | Monitor permission changes specifically |
| `check_all="yes"` | Per-directory | Enable every check type at once (perms, owner, hash, size, timestamps) — most thorough option |

---

## Test Setup

Added a new monitored directory representing a realistic application config path:

```xml
<directories realtime="yes" report_changes="yes" check_all="yes">/etc/myapp-config</directories>
```

---

## Test Results (Actual, Verified)

### 1. File creation
```bash
echo "database_host=localhost" | sudo tee /etc/myapp-config/settings.conf
```
**Result:** Rule `554` fired — "File added to the system." Confirmed via
`alerts.json` parsing.

### 2. Content modification (report_changes)
```bash
echo "database_host=192.168.1.50" | sudo tee /etc/myapp-config/settings.conf
```
**Result:** Rule `550` fired — "Integrity checksum changed." The alert included
the file's `MD5`/`SHA1` hashes after the change, confirming the content hash
was recalculated and flagged as different.

### 3. Ownership change
```bash
sudo chown nobody:nogroup /etc/myapp-config/settings.conf
```
**Result:** Rule `550` fired again, but this time `changed_attributes` showed:
```
Changed attributes: uid,gid,user_name,group_name
Ownership was '0', now it is '65534'
User name was 'root', now it is 'nobody'
Group ownership was '0', now it is '65534'
Group name was 'root', now it is 'nogroup'
```
This confirms `check_all="yes"` tracks **4 separate attributes** for an
ownership change (numeric uid, numeric gid, resolved username, resolved group
name) — not just a single "owner changed" flag. This is more granular than
initially expected.

### 4. File deletion
```bash
sudo rm /etc/myapp-config/settings.conf
```
**Result:** Rule `553` fired — "File deleted." (Not rule 551 or another number
as might be guessed — confirmed the actual rule ID via JSON parsing.)

### Full lifecycle confirmed
```
554 (added) → 550 (modified/content) → 550 (modified/ownership) → 553 (deleted)
```

---

## Dashboard Verification

Checked **Endpoint Security → File Integrity Monitoring → Inventory** on the
`agentvm` agent and confirmed the file inventory view works — searching "setting"
showed 3 unrelated pre-existing files being tracked on the agent
(`qt5-settings-write`, `bios-settings.d/README.md`, `gsettings`), confirming FIM
inventory search works across the whole monitored file set, not just files
created during this test.

> Note: The dashboard inventory check was done against `agentvm`, while the
> actual test file (`settings.conf`) was created on `UbuntuVM` (agent 000) — the
> search results shown were pre-existing files on AgentVM unrelated to today's
> test, not the test file itself.

---

## Why FIM Matters for Real SOC Work

| Attack scenario | What FIM catches |
|---|---|
| Attacker modifies `/etc/passwd` to add a hidden user | File hash changes, alert fires |
| Attacker plants a web shell | New file appears (same mechanism as Day 13's rule 100013) |
| Attacker tampers with a config to disable logging | Content diff / hash change shows the modification |
| Ransomware encrypts files | Mass "modified" events across many files in a short time window |
| Attacker deletes logs to cover their tracks | The deletion itself still gets logged by FIM (rule 553) |

### Compliance connection
FIM is required for **PCI DSS requirement 11.5** — this is why `pci_dss_11.5` has
appeared in rule groups since Day 13's custom rules. Any environment handling
payment card data must have file integrity monitoring in place as a mandatory
control, not an optional one.

---

## Connection to Day 13 Work

This extends what was learned during Day 13's rule-writing struggle with rule
100012 (777 permission detection). That day confirmed FIM's underlying mechanism
works (rule 550 fires reliably on changes), but chaining a *custom* rule off it
remained unresolved. Today confirms rule 550 fires reliably for **multiple**
attribute types (content hash AND ownership), not just permissions — reinforcing
that the built-in FIM detection itself is solid; the open question from Day 13
remains specifically about custom `if_sid` chaining off rule 550, not FIM
detection reliability.

---

## Things I Learned
- `check_all="yes"` tracks ownership as 4 distinct sub-attributes (uid, gid,
  username, groupname) rather than one combined "owner" field
- Rule IDs for the FIM lifecycle are: `554` (added), `550` (modified — covers
  both content AND metadata changes like ownership), `553` (deleted)
- The same rule (`550`) fires for both content changes and ownership changes —
  the distinguishing detail is in the `changed_attributes` field, not the rule ID
- FIM inventory search in the dashboard is scoped per-agent — searching under
  `agentvm` won't show files monitored on `UbuntuVM` (agent 000), and vice versa
- FIM tracks the complete file lifecycle including deletion, which matters for
  detecting attackers trying to cover their tracks by removing evidence
- FIM isn't just a security nice-to-have — it's a mandatory compliance control
  under PCI DSS 11.5 for any environment handling payment data
