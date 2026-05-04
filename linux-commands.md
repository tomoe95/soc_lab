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

## Things I learned
- `cd -` is a quick way to toggle between two directories
- `touch -r` can copy timestamps between files, not just create files
- `file` is useful to check if something is really what its extension says
- `less` is better than `cat` for large log files — cat floods the terminal
- `tail -f` is how SOC analysts watch logs in real time
- `/etc/passwd` doesn't store actual passwords — they're hashed in `/etc/shadow`
- `chmod 600` is the correct permission for SSH private keys
- Files with `777` permissions are a security red flag worth investigating
