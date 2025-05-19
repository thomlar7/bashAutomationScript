#!/usr/bin/env bash

set -e

# ========== OS Check ==========
OS_NAME=$(uname -s)

if [[ "$OS_NAME" == "Linux" ]]; then
  if grep -qi microsoft /proc/version; then
    echo "🟡 Advarsel: Du kjører skriptet i WSL (Windows Subsystem for Linux)."
    echo "Dette kan fungere, men det kan oppstå problemer med nettverk eller systemtjenester som systemd."
  else
    echo "✅ Linux oppdaget."
  fi
elif [[ "$OS_NAME" == "Darwin" ]]; then
  echo "❌ Feil: Du kjører macOS. Dette skriptet er kun laget for Linux."
  exit 1
else
  echo "❌ Feil: Ugyldig operativsystem ($OS_NAME). Dette skriptet støttes kun på Linux eller WSL."
  exit 1
fi

# ========== Default Values ==========
VERBOSE=false
MTU=""
USERS=()
GROUPS=()

# ========== Logging Functions ==========
log() {
  $VERBOSE && echo "$1"
}

# ========== Usage Function ==========
usage() {
  echo "Usage: $0 [--users \"user1 user2\"] [--groups \"group1 group2\"] [--mtu 1442] [--verbose|-v]"
  exit 1
}

# ========== Parse Arguments ==========
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --users)
      IFS=' ' read -r -a USERS <<< "$2"
      shift 2
      ;;
    --groups)
      IFS=' ' read -r -a GROUPS <<< "$2"
      shift 2
      ;;
    --mtu)
      MTU="$2"
      shift 2
      ;;
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    *)
      usage
      ;;
  esac
done

# ========== OS Detection ==========
detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "${ID,,}"
  else
    echo "unknown"
  fi
}

DISTRO=$(detect_os)
log "Detected OS: $DISTRO"

# ========== Install Dependencies ==========
install_docker() {
  case "$DISTRO" in
    ubuntu|debian)
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl gnupg lsb-release
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      echo \  
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO \$(lsb_release -cs) stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      ;;
    fedora)
      sudo dnf -y install dnf-plugins-core
      sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
      sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      ;;
    alpine)
      sudo apk update
      sudo apk add docker docker-cli docker-compose
      ;;
    *)
      echo "Unsupported OS: $DISTRO"
      exit 1
      ;;
  esac

  sudo systemctl enable docker
  sudo systemctl start docker
}

install_docker

# ========== User and Group Handling ==========
create_users() {
  for user in "${USERS[@]}"; do
    if id "$user" &>/dev/null; then
      echo "User '$user' already exists."
    else
      sudo useradd -m "$user"
      echo "User '$user' created."
    fi
  done
}

create_groups() {
  for group in "${GROUPS[@]}"; do
    if getent group "$group" > /dev/null; then
      echo "Group '$group' already exists."
    else
      sudo groupadd "$group"
      echo "Group '$group' created."
    fi

    for user in "${USERS[@]}"; do
      if id "$user" &>/dev/null; then
        if id -nG "$user" | grep -qw "$group"; then
          echo "User '$user' is already in group '$group'."
        else
          sudo usermod -aG "$group" "$user"
          echo "User '$user' added to group '$group'."
        fi
      fi
    done
  done
}

create_users
create_groups

# ========== Docker MTU Configuration ==========
configure_mtu() {
  if [ -n "$MTU" ]; then
    echo "{\n  \"mtu\": $MTU\n}" | sudo tee /etc/docker/daemon.json > /dev/null
    sudo systemctl restart docker
    echo "Docker MTU set to $MTU"
  else
    echo "Default MTU used."
  fi
}

configure_mtu

# ========== Logging Driver (default to json-file) ==========
configure_logging() {
  sudo mkdir -p /etc/docker
  echo '{
  "log-driver": "json-file"
}' | sudo tee /etc/docker/daemon.json > /dev/null
  sudo systemctl restart docker
  echo "Docker logging driver configured to json-file."
}

configure_logging

log "Installation complete."
exit 0
5