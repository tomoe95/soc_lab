# Day 15 — Linux Log Sources

## Overview
Explored the main Linux log files, log rotation mechanics, live log filtering
techniques, and discovered how SSH key-only authentication changes what "failed
login" events actually look like.

---

## Main Log Files

| File | Contents |
|---|---|
| `/var/log/syslog` | General system messages — services starting/stopping, kernel events, cron |
| `/var/log/auth.log` | Authentication events — logins, sudo usage, SSH activity |
| `/var/log/kern.log` | Kernel-specific messages — hardware, drivers, low-level errors |
| `/var/log/journal/` | systemd's binary journal (read with `journalctl`, not `cat`) |
| `/var/log/dpkg.log` | Package install/remove/upgrade history |

---

## Log Rotation

Logs don't grow forever — `logrotate` archives and compresses them automatically.

### Naming pattern observed
```
syslog        ← current, active log (still being written to)
syslog.1      ← most recently rotated, NOT compressed yet
syslog.2.gz   ← 2 rotations old, compressed
syslog.3.gz   ← 3 rotations old, compressed
syslog.4.gz   ← oldest kept, compressed
```
Once a 5th rotation happens, `syslog.4.gz` is deleted to make room.

### Config file: `/etc/logrotate.d/rsyslog`
```
/var/log/syslog
/var/log/mail.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/cron.log
{
    rotate 4
    weekly
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
```

| Directive | Meaning |
|---|---|
| File list at top | All these logs share the same rotation rules below |
| `rotate 4` | Keep only 4 old copies — 5th oldest gets deleted |
| `weekly` | Rotate once every week |
| `missingok` | Don't error if a listed file doesn't exist |
| `notifempty` | Don't rotate an empty file |
| `compress` | Compress rotated files into `.gz` |
| `delaycompress` | Wait one extra cycle before compressing — prevents corruption if a process still has the file open |
| `sharedscripts` | Run the postrotate script once total, not once per file |
| `postrotate...endscript` | Tells `rsyslog` to reopen the fresh log file after rotation |

### Rotation lifecycle
```
Week 0:  syslog (active)
Week 1:  syslog.1 (rotated, not compressed - delaycompress)
Week 2:  syslog.2.gz (now compressed), new syslog.1
Week 3:  syslog.3.gz, syslog.2.gz, syslog.1
Week 4:  syslog.4.gz, syslog.3.gz, syslog.2.gz, syslog.1
Week 5:  syslog.4.gz DELETED (rotate 4 limit), everything shifts down
```

> 💡 **SOC relevance:** If an attacker was active more than ~4-5 weeks ago, that
> evidence may already be gone under this default retention policy. Real
> organizations often configure 90+ day retention for forensic/compliance needs.

---

## Live Log Filtering Technique

Watching a log in real time, filtered to only what matters — a core SOC analyst skill:

```bash
sudo tail -f /var/log/auth.log | grep --line-buffered -i "invalid\|failed\|refused"
```

- `tail -f` — streams new lines as they're written
- `grep --line-buffered` — necessary when piping `tail -f` into `grep`, otherwise
  grep buffers output and nothing appears until the buffer fills
- `-i` — case-insensitive matching
- `\|` inside quotes — OR logic between multiple patterns

---

## Key Discovery: Password Auth Disabled Changes Failed Login Behavior

Since `PasswordAuthentication no` was set on Day 5, trying a wrong password no
longer works the traditional way:
```bash
ssh -p 2222 wronguser@127.0.0.1
# Result: "Permission denied (publickey)." — no password prompt at all
```

**Filtering for the word "Failed" produces nothing**, because the log message
format is different when key-only auth is enforced.

### What actually appears in auth.log instead:
```
Invalid user wrong from 10.0.2.2 port 55662
Connection closed by invalid user wrong 10.0.2.2 port 55662 [preauth]
```

| Field | Meaning |
|---|---|
| `Invalid user X` | Username doesn't exist on the system |
| `from 10.0.2.2` | Source IP — this is the VirtualBox NAT gateway (Mac's traffic through NAT) |
| `[preauth]` | Connection closed **before** authentication completed — since the user doesn't even exist, there's nothing to authenticate against |

### The real distinction this revealed
| Attack Type | Requires | What it looks like in logs |
|---|---|---|
| Password brute force | `PasswordAuthentication yes` | Multiple "Failed password for X" entries |
| Username enumeration | Works even with key-only auth | Multiple "Invalid user X" entries — MITRE T1087 |

Since this lab has password auth disabled, real brute force testing (planned for
Day 19) will need password auth temporarily re-enabled on a throwaway test
account, OR the test should focus on username enumeration detection instead.

---

## Things I Learned
- `.gz` files in `/var/log/` are compressed historical copies, not currently active logs
- `delaycompress` exists specifically to avoid corrupting a log file that a process
  might still have open at the exact rotation moment
- `grep --line-buffered` is required when filtering a live `tail -f` stream —
  without it, grep waits for its internal buffer to fill before showing anything
- Disabling password authentication (Day 5 hardening) means traditional "Failed
  password" brute force log entries never appear — need to adjust detection
  strategy and future test plans accordingly
- "Invalid user" entries with `[preauth]` indicate the connection was rejected
  before any credential exchange — the username itself was already invalid
- `10.0.2.2` is VirtualBox's NAT gateway address — traffic from the Mac host
  arrives at the VM appearing to come from this IP, not the Mac's real LAN IP
- This lab's SSH hardening (Day 5) inadvertently changed what Day 19's planned
  brute force simulation will actually need to test — worth revisiting that plan
