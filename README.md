# 🚀 Linux Docker Automation Script

A flexible and fully automated Bash script for setting up Docker and Docker Compose v2 on Linux systems. This script also handles user and group management, Docker daemon configuration (MTU & logging), and is WSL-aware for smoother cross-platform compatibility.

---

## 🎯 Features

- 🔍 **Automatic OS Detection**  
  Detects supported Linux distros and chooses the correct package manager (`apt`, `dnf`, or `apk`).

- 🐳 **Docker & Docker Compose v2 Installation**  
  Uses official methods recommended by Docker documentation.

- 👤 **User and Group Management**  
  Create users and groups safely. Adds users to specified groups only if necessary.

- ⚙️ **Docker Daemon Configuration**  
  - Custom MTU (useful for VPNs/cloud setups)  
  - Logging driver set to `json-file` by default

- 🧠 **WSL Detection**  
  Detects Windows Subsystem for Linux and warns about limitations (like missing `systemd`).

- 📢 **Verbose Logging for Debugging**  
  Enables extra output when needed for troubleshooting.

---

## 📦 Supported Linux Distributions

- Ubuntu / Debian
- Fedora
- Alpine Linux
- WSL (Windows Subsystem for Linux)

---

## 🧪 Example Usage

```bash
chmod +x ./myBashScript.sh

./myBashScript.sh \
  --users "john jane" \
  --groups "devs testers" \
  --mtu 1442 \
  --verbose
```

🧰 Script Options
Option	Description
--users	Space-separated list of usernames to create
--groups	Space-separated list of groups to create
--mtu	Custom MTU value for Docker daemon
--verbose -v	Enable debug/verbose output

🛑 Requirements
A Linux system (or WSL)

sudo access

Internet connection (to install Docker and dependencies)

📌 Notes
The script is safe to re-run; it checks for existing users, groups, and Docker status.

WSL users will get a warning due to possible limitations with systemctl and background services.

