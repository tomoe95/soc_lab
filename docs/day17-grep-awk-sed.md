# Day 17 — grep, awk, sed for Log Parsing

## Tools Summary

| Tool | Best for | Key flags used |
|---|---|---|
| grep | Finding lines matching a pattern | `-i` (case-insensitive), `-o` (only matched part), `-P` (Perl regex), `-a` (force text mode), `-c` (count) |
| awk | Column/field extraction, counting | `$0` (whole line), `$NF` (last field), `$(NF-n)` (nth from end), `pattern {action}` |
| sed | Find/replace, deleting lines, ranges | `s/old/new/` (substitute), `/pattern/d` (delete), `-n '/start/,/end/p'` (range print) |

---

## Key Debugging Lessons

### Binary file matches error
`tail -n 100 file > newfile` occasionally captures stray non-text bytes.
Fix: use `grep -a` to force text mode, or clean with `strings file > cleanfile`.

### $NF field counting requires manual verification
Counting fields from the end only works reliably when checked against a real
sample line first. In this log format:

```
... Invalid user wrong from 10.0.2.2 port 55662
                              NF-2      NF-1  NF
```

`$NF` = port number, NOT the IP — the label word "port" sits between them,
making `$(NF-2)` the correct field for the IP address, not `$(NF-1)`.

### sed date range matching needs partial timestamps
Exact minute-level timestamps (`10:00`) rarely match real log entries that
happened at odd times (`10:05`, `10:08`). Match just the hour prefix instead:

```bash
sed -n '/2026-07-15T10:/,/2026-07-15T11:/p' file
```

### Combining tools for real analysis
```bash
grep -a "Invalid user" file | awk '{print $6}' | sort | uniq -c | sort -rn | head -5
```
This answers "what are the most attempted usernames?" — a genuinely useful
SOC query, but only works correctly once the right awk field is identified
through manual verification, not assumption.

### Time range + noise filtering combo
```bash
sed -n '/START/,/END/p' file | grep -v "CRON"
```
Real investigations require both narrowing by time AND filtering out routine
background noise (cron jobs, your own commands) to find genuinely relevant events.

---

## Script Improvement

Added a "Top Attempted Invalid Usernames" section to `count-logs.sh` using:
```bash
grep -oP "Invalid user \K\S+" "$AUTHLOG" | sort | uniq -c | sort -rn | head -10
```

---

## Things I Learned
- Always verify field position with a real sample line before trusting `$NF` math
- `grep -a` is a quick fix for "binary file matches" errors from redirected logs
- sed's range printing is genuinely useful for time-boxed incident investigation
- Combining `grep` + `awk` + `sort` + `uniq -c` + `sort -rn` is the core "top N" pattern
  used constantly in log analysis
- Real log analysis output is rarely clean — expect noise (cron, your own
  commands) and plan to filter it out as a separate step
