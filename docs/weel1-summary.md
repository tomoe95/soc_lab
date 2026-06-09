# Week 1 Summary — Linux Fundamentals

**Period:** Day 1–7
**Goal:** Build a stable Linux lab environment ready for Wazuh SIEM installation

---

## What I Built
- Ubuntu 24.04 LTS ARM64 VM running on VirtualBox (Apple Silicon Mac)
- SSH key-based access from Mac to VM via port forwarding (port 2222)
- 3 bash scripts for system monitoring (uptime, processes, log analysis)
- Linux command cheat sheet covering navigation, permissions, users, SSH, systemd

## Skills Practiced
- Linux filesystem navigation and file management
- User, group, and permission management (chmod, chown)
- Bash scripting with variables, loops, conditionals, and log output
- SSH hardening — key-based auth, disabled password login
- systemd service management (systemctl, journalctl, unit files)

## Key Lessons Learned
- SSH key-based auth blocks brute force — no password means nothing to guess
- Disabling ssh.service doesn't fully stop SSH if ssh.socket is still active
- Files with 777 permissions are a security red flag worth alerting on
- journalctl -p err is the fastest way to triage errors on a Linux system
- Services without Restart=on-failure won't recover if killed — attackers exploit this
- AppArmor DENIED lines in logs indicate blocked process access attempts

## Challenges & How I Solved Them
- ARM64 ISO issue → downloaded correct ARM64 Ubuntu server ISO from mirror
- VirtualBox Guest Additions not supported on ARM64 → used Python HTTP server workaround
- SSH connection refused after reboot → fixed with systemctl enable ssh
- Divergent git branches → resolved with git config pull.rebase false

## Lab State
- VM snapshot taken: `week1-clean-baseline`
- SSH: key-based only, password auth disabled
- All scripts tested and working

## Next Week — Week 2: Wazuh SIEM
- Day 8: Deploy Wazuh manager (all-in-one installer)
- Day 9: Explore Wazuh dashboard
- Day 10: Install first Linux agent
