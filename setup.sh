#!/bin/bash

################ BASIC VARIABLES, FUNCTIONS, SETTINGS ######################

# Exit on any error
set -euo pipefail

# Log & Error function
err() { echo "ERROR: $*"; exit 1; } 
info() { echo "INFO: $*"; }

# .env relative location
env_file="./.env"

################### CHECKING PREREQUISITES ###############################
info "Checking prerequisites....."

# If .env doesn't exists, error out
[[ -f "${env_file}" ]] || err "Config file not found: ${env_file}"

# Load .env
source "${env_file}"

# Check tailscale auth key in .env
[[ -z "${TAILSCALE_AUTH_KEY:-}" ]] && err "TAILSCALE_AUTH_KEY not set"


# Check root user id
if [ "$(id -u)" -ne 0 ]; then
    err "This script must be run as root (sudo)"
fi

################### INSTALLATIONS ########################################
info "Updating repositories and upgrade packages....."

# Update repositories and upgrade packages
apt-get update > /dev/null && apt-get -y upgrade > /dev/null

info "Installing tailscale........."
# Install tailscale
curl -fsSL https://tailscale.com/install.sh | sh > /dev/null
tailscale up --auth-key=$TAILSCALE_AUTH_KEY --accept-dns=false

info "Installing docker......"
# Copied from docker docs

# Add Docker's official GPG key:
apt install ca-certificates curl > /dev/null
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Update repositories
apt update > /dev/null

# Install docker
apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null
systemctl start docker

################### SMB SETUP ###############################################################
info "Installing and configuring Samba......"

# Install samba
apt -y install samba > /dev/null

# Create /srv directory for shares
mkdir -p ${SMB_SHARE_PATH}
chmod 777 ${SMB_SHARE_PATH}

# Backup original smb.conf
cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

# Create new smb.conf with secure configuration
tee /etc/samba/smb.conf <<EOF
[global]
   workgroup = WORKGROUP
   server string = Samba Server %v
   netbios name = homelab
   security = user
   map to guest = never
   dns proxy = no

   # Logging
   log file = /var/log/samba/log.%m
   max log size = 1000
   syslog only = no
   syslog = 0

   # Default id mapping
   idmap config * : backend = tdb
   idmap config * : range = 1000-9999

[shares]
   comment = Shared Folder
   path = ${SMB_SHARE_PATH}
   browseable = yes
   writable = yes
   guest ok = no
   public = no
   create mask = 0644
   directory mask = 0755
   valid users = @smbusers
EOF

# Create samba users group
groupadd -f smbusers

# Check for SMB credentials in .env
if [[ -z "${SMB_USER:-}" ]] || [[ -z "${SMB_PASSWORD:-}" ]]; then
    info "SMB_USER or SMB_PASSWORD not set in .env, creating default samba user..."
    SMB_USER="smbuser"
    SMB_PASSWORD="changeme123"
fi

# Create system user for samba if it doesn't exist
if ! id "$SMB_USER" &>/dev/null; then
    useradd -M -s /usr/sbin/nologin "$SMB_USER"
fi

# Add user to samba users group
usermod -a -G smbusers "$SMB_USER"

# Set samba password
echo -e "$SMB_PASSWORD\n$SMB_PASSWORD" | smbpasswd -a "$SMB_USER" -s

# Enable and start samba services
systemctl enable smbd nmbd > /dev/null
systemctl start smbd nmbd

################### DNS SETUP ###############################################################
info "Setting up DNS...."

# Disable systemd-resolved
systemctl stop systemd-resolved > /dev/null
systemctl disable systemd-resolved > /dev/null

# Configure DNS servers
rm -f /etc/resolv.conf
tee /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# Make /etc/resolv.conf immutable
chattr +i /etc/resolv.conf

##################### STARTING SERVICES #####################################################
info "Starting services......"

# Folders and files cert generation
mkdir -p ./cert
touch ./cert/acme.json
chmod 600 ./cert/acme.json

# Starting services
systemctl restart docker
[[ -f docker-compose.yaml ]] || err "docker-compose.yaml not found"
docker compose up -d
