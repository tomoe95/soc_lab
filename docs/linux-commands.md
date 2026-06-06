# Linux Command Cheat Sheet

## Important Directories
| Path | What's inside |
|---|---|
| `/etc` | System config files |
| `/var/log` | System log files |
| `/home` | User home directories |
| `/root` | Home directory for the root (admin) user |
| `/tmp` | Temporary files, cleared on reboot |
| `/proc` | Live info about running processes (not real files) |

---

## Navigation
| Command | Example | What it does |
|---|---|---|
| `pwd` | `pwd` | Print current directory path |
| `cd` | `cd /var/log` | Change to a directory |
| `cd` | `cd ..` | Go up one level |
| `cd` | `cd -` | Go back to previous directory |
| `ls` | `ls -la` | List all files including hidden ones, with details |

---

## File Management
| Command | Example | What it does |
|---|---|---|
| `mkdir` | `mkdir myfolder` | Create a new directory |
| `rm` | `rm file.txt` | Delete a file |
| `rm` | `rm -rf myfolder` | Delete a folder and everything inside it |
| `cp` | `cp file1.txt file2.txt` | Copy a file |
| `mv` | `mv old.txt new.txt` | Move or rename a file |
| `touch` | `touch file.txt` | Create an empty file |
| `touch -r` | `touch -r f1.txt f2.txt` | Set f2.txt's timestamp to match f1.txt's |

---

## File Inspection
| Command | Example | What it does |
|---|---|---|
| `file` | `file README.md` | Describe what kind of file it is |
| `cat` | `cat file.txt` | Print entire file content to screen |
| `less` | `less file.txt` | View large files page by page (see shortcuts below) |
| `head` | `head -n 20 file.txt` | Show first 20 lines |
| `tail` | `tail -n 20 file.txt` | Show last 20 lines |
| `tail -f` | `tail -f /var/log/syslog` | Watch a log file update in real time |

---

## User & Identity
| Command | Example | What it does |
|---|---|---|
| `id` | `id` | Show your own uid, gid, and groups |
| `id` | `id root` | Show uid, gid, and groups for the root user |
| `whoami` | `whoami` | Print your current username |
| `groups` | `groups` | List all groups the current user belongs to |

---

## Shortcuts Inside `less`
> Enter less with: `less filename.txt` — quit anytime with `q`

| Key | What it does |
|---|---|
| `g` | Go to beginning of file |
| `G` | Go to end of file |
| `/search_term` | Search forward for "search_term" |
| `?search_term` | Search backward for "search_term" |
| `n` | Jump to next match |
| `N` | Jump to previous match |
| `q` | Quit less |

---

# Users, Groups & Permissions

## Viewing Users and Groups
| Command | What it does |
|---|---|
| `cat /etc/passwd` | List all system users |
| `cat /etc/group` | List all groups and their members |
| `groups` | Show groups the current user belongs to |

### /etc/passwd format
```
username : x : uid : gid : user_info : home_directory : shell
test    : x  : 1000: 1000: Test      : /home/test     : /bin/bash
```
- `x` in the password field means the password is stored in `/etc/shadow` (not shown here)

### /etc/group format
```
group_name : x : group_id : members
sudo       : x : 27       : test
```
 
---

## Permission Bits
 
Every file has 3 permission groups: **owner**, **group**, **others**
 
```
-rwxr-xr--
 ^^^         owner  (rwx = read, write, execute)
    ^^^      group  (r-x = read, no write, execute)
       ^^^   others (r-- = read only)
```
| Symbol | Number | Meaning |
|---|---|---|
| `r` | 4 | Read |
| `w` | 2 | Write |
| `x` | 1 | Execute |
| `-` | 0 | No permission |

### Common chmod values
| Command | Result | Who can do what |
|---|---|---|
| `chmod 777 file` | `rwxrwxrwx` | Everyone can read, write, execute |
| `chmod 755 file` | `rwxr-xr-x` | Owner full, others can read & run |
| `chmod 700 file` | `rwx------` | Only owner can do anything |
| `chmod 644 file` | `rw-r--r--` | Owner read/write, others read only |
| `chmod 600 file` | `rw-------` | Only owner can read/write (e.g. SSH keys) |
 
> 💡 **SOC tip:** Files with `777` permissions are a red flag — anyone can modify them.
 
---

## chmod & chown
 
| Command | Example | What it does |
|---|---|---|
| `chmod` | `chmod 700 secret.txt` | Set permissions using octal number |
| `chmod` | `chmod +x script.sh` | Add execute permission |
| `chmod` | `chmod -w file.txt` | Remove write permission |
| `chown` | `chown alice file.txt` | Change owner of a file |
| `chown` | `chown alice:devs file.txt` | Change owner AND group |
| `chown` | `chown -R alice myfolder/` | Change owner recursively for a folder |
 
---

# SSH & Remote Access
 
## Key Concepts
- SSH (Secure Shell) lets you control a remote Linux machine from your terminal
- **Key-based auth** is more secure than passwords — uses a public/private key pair
- The **private key** stays on the local (Mac) only — never share it
- The **public key** is copied to the server — it's safe to share
```
[ Mac ]                        [ Ubuntu VM ]
  Private key  ──── SSH connect ───▶  Public key
  (~/.ssh/id_ed25519)                 (~/.ssh/authorized_keys)
```
 
## Generating SSH Keys (on Mac)
| Command | What it does |
|---|---|
| `ssh-keygen -t ed25519 -C "label"` | Generate a new ed25519 key pair with a label |
 
### Key files generated
| File | Location | Purpose |
|---|---|---|
| Private key | `~/.ssh/id_ed25519` | Stays on local (Mac) only |
| Public key | `~/.ssh/id_ed25519.pub` | Copied to the server |
 
## Copying Key to Server
| Command | Example | What it does |
|---|---|---|
| `ssh-copy-id` | `ssh-copy-id -p 2222 user@127.0.0.1` | Copies your public key to the server's `authorized_keys` |
 
## Connecting via SSH
| Command | Example | What it does |
|---|---|---|
| `ssh` | `ssh user@192.168.1.10` | Connect to a server on default port 22 |
| `ssh -p` | `ssh -p 2222 user@127.0.0.1` | Connect on a custom port (e.g. port forwarded VM) |
 
## SSH Service Management (on Ubuntu VM)
| Command | What it does |
|---|---|
| `sudo service ssh start` | Start the SSH server |
| `sudo service ssh stop` | Stop the SSH server |
| `sudo service ssh restart` | Restart after config changes |
| `sudo service ssh status` | Check if SSH is running |
 
## Hardening SSH (/etc/ssh/sshd_config)
| Setting | Value | Why |
|---|---|---|
| `PasswordAuthentication` | `no` | Blocks brute force — only key login allowed |
| `PubkeyAuthentication` | `yes` | Enables key-based login |
 
> ⚠️ **Always verify your key works before disabling password auth** — or you risk locking yourself out of a remote server permanently.
 
## VirtualBox Port Forwarding (NAT workaround)
Since VirtualBox NAT blocks direct host-to-VM connections, forward a port:
 
| Field | Value |
|---|---|
| Name | ssh |
| Protocol | TCP |
| Host IP | 127.0.0.1 |
| Host Port | 2222 |
| Guest IP | 10.0.2.15 |
| Guest Port | 22 |
 
Then connect with: `ssh -p 2222 user@127.0.0.1`
 
---

# systemd & Service Management

## systemctl — Control Services
| Command | Example | What it does |
|---|---|---|
| `systemctl status` | `sudo systemctl status ssh` | Show if service is running |
| `systemctl start` | `sudo systemctl start ssh` | Start a service |
| `systemctl stop` | `sudo systemctl stop ssh` | Stop a service |
| `systemctl restart` | `sudo systemctl restart ssh` | Stop then start a service |
| `systemctl enable` | `sudo systemctl enable ssh` | Auto-start on boot |
| `systemctl disable` | `sudo systemctl disable ssh` | Disable auto-start on boot |

## journalctl — View Logs
| Command | What it does |
|---|---|
| `journalctl` | View all system logs |
| `journalctl -u ssh` | View logs for a specific service |
| `journalctl -f` | Watch logs in real time |
| `journalctl -b` | Show logs since last boot only |
| `journalctl -n 20` | Show last 20 lines |
| `journalctl -p err` | Show error level logs only |
| `journalctl --since "2024-01-01" --until "2024-12-31"` | Filter by time range |

### 📍 Log levels (most → least severe)
`emerg` → `alert` → `crit` → `err` → `warning` → `notice` → `info` → `debug`

## Service Unit File Structure
> Location: `/lib/systemd/system/servicename.service`

| Section | Purpose |
|---|---|
| `[Unit]` | Description and dependencies |
| `[Service]` | How to start, stop, reload the service |
| `[Install]` | When to start during boot |

### Key fields
| Field | Meaning |
|---|---|
| `After=` | Start only after these services are running |
| `ExecStart=` | Command that starts the service |
| `ExecReload=` | Command to reload config without full restart |
| `Restart=on-failure` | Auto-restart if the service crashes |
| `RestartSec=42s` | Wait this long before restarting after a crash |
| `WantedBy=multi-user.target` | Start on normal system boot |
| `EnvironmentFile=` | Load extra settings from a file |
| `Type=notify` | Service tells systemd when it's fully ready |

 
## Things I learned
- systemd has two SSH units: ssh.service (always running) and ssh.socket (starts on demand)
- Disabling ssh.service doesn't fully disable SSH if ssh.socket is still active
- journalctl -p err filters only errors — useful for quick incident triage
- apparmor="DENIED" in logs means a process was blocked from accessing a file
- A service without Restart=on-failure won't recover if killed — attackers exploit this
- ConditionPathExists in unit files means the service only starts if certain files exist
