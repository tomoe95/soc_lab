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

## Things I learned today
- `cd -` is a quick way to toggle between two directories
- `touch -r` can copy timestamps between files, not just create files
- `file` is useful to check if something is really what its extension says
- `less` is better than `cat` for large log files — cat floods the terminal
- `tail -f` is how SOC analysts watch logs in real time
