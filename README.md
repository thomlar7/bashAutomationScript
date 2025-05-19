🚀 Linux Docker Automation Script
This Bash script automates the full setup of Docker and Docker Compose v2 on various Linux distributions — including Ubuntu, Debian, Fedora, Alpine, and even WSL (Windows Subsystem for Linux). It also manages users, groups, and Docker daemon configurations in a safe and repeatable way.

🎯 Key Features
🔍 OS Detection
Automatically detects the underlying Linux distribution and selects the appropriate package manager (apt, dnf, or apk).

🐳 Docker & Compose Installation
Installs Docker and Docker Compose v2 using official installation methods, ensuring compatibility and best practices.

👥 User and Group Management
Supports creating users and groups via flags:

bash
Kopier
Rediger
./install.sh --users "john jane" --groups "devs testers"
⚙️ Docker Daemon Configuration

Optional MTU configuration:

bash
Kopier
Rediger
./install.sh --mtu 1442
Sets logging driver to json-file for consistency.

📢 Verbose Output
Enable debug logging to help trace any setup issues:

bash
Kopier
Rediger
./install.sh --verbose
✅ WSL Support
Detects and runs under WSL with a clear warning about potential limitations (e.g., no systemd).

🧪 Example Usage
bash
Kopier
Rediger
./install.sh --users "Ed Kelly Bortus" --groups "Crew Officers" --mtu 1442 --verbose
📦 Supported Distributions
Ubuntu / Debian (APT)

Fedora (DNF)

Alpine (APK)

WSL (Windows Subsystem for Linux)

🛠 Requirements
Linux-based OS

sudo privileges

Internet connection for installing Docker

Script must be marked as executable:

bash
Kopier
Rediger
chmod +x ./install.sh
