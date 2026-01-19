# Docker Traefik Homelab

A comprehensive homelab setup using Docker Compose, Traefik reverse proxy, and various self-hosted services. This project provides an automated, scalable infrastructure for running multiple containerized applications behind a unified reverse proxy with automatic HTTPS/TLS termination.

## Features

- **Traefik Reverse Proxy**: Automatic SSL/TLS with Let's Encrypt and Cloudflare DNS challenge
- **Portainer**: Docker container management UI
- **GitLab**: Self-hosted Git repository and CI/CD platform
- **Jellyfin**: Media streaming server for movies and TV shows
- **qBittorrent**: Torrent client with web UI
- **Backrest**: Backup orchestration tool
- **Beszel**: System monitoring and analytics
- **Technitium DNS**: Self-hosted DNS server
- **Samba/SMB**: Network file sharing

## Prerequisites

- Ubuntu/Debian-based Linux system
- Root or sudo access
- Domain name with DNS access (for Cloudflare)
- Cloudflare API token (optional, for automatic DNS validation)

## Quick Start

1. **Clone the repository**:
```bash
sudo -i
cd <to your preferred folder>
git clone https://github.com/springmannsan/docker-traefik-homelab.git
cd docker-traefik-homelab
```

2. **Configure environment variables**:
```bash
cp example.env .env
nano .env  # Edit with your settings
```

3. **Run the setup script**:
```bash
chmod 700 setup.sh
./setup.sh
```

The script will:
- Update system packages
- Install Docker and Docker Compose
- Install Tailscale for secure VPN connectivity
- Configure Samba/SMB file sharing
- Set up all Docker services

## Configuration

### Environment Variables

Edit `.env` to configure:

| Variable | Description | Required |
|----------|-------------|----------|
| `TRAEFIK_DASHBOARD_CREDENTIALS` | Basic auth credentials for Traefik dashboard (format: `user:hashed_password`) | Yes |
| `CF_DNS_API_TOKEN` | Cloudflare API token for DNS-01 challenge | Yes |
| `DOMAIN_NAME` | Your domain name (e.g., `example.com`) | Yes |
| `EMAIL` | Email for Let's Encrypt certificate notifications | Yes |
| `TAILSCALE_AUTH_KEY` | Tailscale authentication key | Yes |
| `DNS_PASSWORD` | Password for Technitium DNS access | Yes |
| `SMB_SHARE_PATH` | Path for Samba file shares | Yes |
| `SMB_USER` | Samba user name | Yes |
| `SMB_PASSWORD` | Samba user password | Yes |
| `MOVIES_PATH` | Path to movies directory (Jellyfin) | Optional |
| `TV_PATH` | Path to TV shows directory (Jellyfin) | Optional |
| `DOWNLOADS_PATH` | Path to downloads directory (qBittorrent) | Optional |
| `TOKEN` | Beszel authentication token | Required for Beszel |
| `KEY` | Beszel authentication key | Required for Beszel |

### Access Services

Once deployed, services are accessible via:

- **Traefik Dashboard**: `https://dashboard.<DOMAIN_NAME>`
- **Portainer**: `https://portainer.<DOMAIN_NAME>`
- **GitLab**: `https://gitlab.<DOMAIN_NAME>`
- **Jellyfin**: `https://jellyfin.<DOMAIN_NAME>`
- **qBittorrent**: `https://torrent.<DOMAIN_NAME>`
- **Backrest**: `https://backrest.<DOMAIN_NAME>`
- **Beszel**: `https://beszel.<DOMAIN_NAME>`
- **DNS Server**: `http://technitium.<DOMAIN_NAME>:5380`

All services are automatically secured with Let's Encrypt SSL/TLS certificates.

## Project Structure

```
docker-traefik-homelab/
├── docker-compose.yaml       # Main services (Traefik, Portainer, DNS)
├── setup.sh                  # Automated setup script
├── example.env               # Environment variables template
├── .gitignore               # Git ignore rules
├── cert/                    # SSL/TLS certificates directory
│   └── acme.json           # Let's Encrypt certificate storage
└── services/
    ├── backrest/           # Backup orchestration
    ├── beszel/             # System monitoring
    ├── gitlab/             # Git repository & CI/CD
    └── streaming/          # Media servers (Jellyfin, qBittorrent)
```

## Docker Network

All services communicate via the `proxy` overlay network. This network is created by Traefik and allows inter-container communication while maintaining security through network segmentation.

## Security Considerations

- **Environment Variables**: Sensitive data is stored in `.env` (excluded from git via `.gitignore`)
- **SSL/TLS**: All external communication is encrypted with Let's Encrypt certificates
- **Basic Auth**: Traefik dashboard is protected with HTTP Basic Authentication
- **Docker Socket**: Only necessary services have access to the Docker socket
- **Tailscale Integration**: Secure VPN access to the homelab infrastructure

## Backup & Restore

Backrest is included for automated backups of:
- Docker volumes
- Critical configuration files
- Application data

Configure backup destinations and schedules in Backrest UI.

## Monitoring

Beszel provides:
- Real-time system monitoring
- Container resource usage tracking
- Historical performance data
- Alerts and notifications

Access the Beszel dashboard for complete infrastructure visibility.

## Troubleshooting

### Services not accessible
- Check DNS resolution: `nslookup <service>.<DOMAIN_NAME>`
- Verify Traefik logs: `docker logs traefik`
- Ensure certificates are generated: Check `cert/acme.json`

### Certificate errors
- Check Cloudflare API token is valid
- Verify domain is pointing to correct IP
- Check Let's Encrypt rate limits haven't been exceeded

### Tailscale connection issues
- Verify `TAILSCALE_AUTH_KEY` is correct
- Check Tailscale service status: `tailscale status`
- Re-authenticate: `tailscale up --auth-key=<NEW_KEY>`

## License

See LICENSE file for details.

## Support

For issues or questions, please open an issue on GitHub.