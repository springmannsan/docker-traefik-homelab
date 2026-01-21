# Docker Traefik Homelab

A comprehensive Docker-based homelab infrastructure stack designed to manage and deploy multiple services using Traefik as a reverse proxy and ingress controller.

## Overview

This project provides a complete infrastructure setup for a self-hosted homelab environment with:
- **Traefik v3.6.1** - Modern reverse proxy and ingress controller with automatic SSL/TLS
- **Cloudflare Integration** - DNS management and tunneling for secure external access
- **Portainer** - Docker container management UI
- **Multiple Services** - Pre-configured deployments for specialized applications

## Key Features

- **Automatic HTTPS** - Let's Encrypt SSL certificates with Cloudflare DNS challenges
- **Traefik Dashboard** - Built-in web UI for monitoring and managing routes (with basic auth)
- **Docker Networking** - Isolated proxy network for inter-container communication
- **Cloudflare Tunnel** - Secure external connectivity without exposing ports directly
- **Infrastructure as Code** - Automated setup script for quick deployment

## Services Included

The homelab includes the following services:

- **backrest/** - Backup and restore management
- **beszel/** - System monitoring and resource tracking
- **gitlab/** - GitLab instance for version control and CI/CD
- **mysql/** - MySQL database server
- **streaming/** - Media streaming service

## Project Structure

```
docker-traefik-homelab/
├── docker-compose.yaml       # Main services (Traefik, Portainer, Cloudflare)
├── setup.sh                  # Automated setup script for initial deployment
├── example.env               # Environment variables template
├── services/                 # Individual service configurations
│   ├── backrest/
│   ├── beszel/
│   ├── gitlab/
│   ├── mysql/
│   └── streaming/
└── README.md
```

## Getting Started

### Prerequisites

- Linux-based system (script targets Ubuntu)
- Root/sudo access
- Cloudflare account with DNS API token
- Tailscale account (optional, for VPN access)
- Docker and Docker Compose
- Local DNS server
- Global domain is optional

### Configuration

1. Local DNS record
    - `*.home.example.local` for local services

2. Copy the environment template:
   ```bash
   cp example.env .env
   ```

3. Get cloudflare tunnel token

4. Configure the `.env` file with your settings:
   - `CLOUDFLARE_TUNNEL_TOKEN` - Your Cloudflare tunnel token
   - `CF_DNS_API_TOKEN` - Cloudflare DNS API token for Let's Encrypt challenges
   - `TRAEFIK_DASHBOARD_CREDENTIALS` - Basic auth credentials (format: `user:password`)
   - `DOMAIN_NAME` - Your domain for accessing services
   - `EMAIL` - Email for Let's Encrypt certificate notifications
   - `TAILSCALE_AUTH_KEY` - Tailscale authentication key (if using Tailscale VPN)
   - `SMB_SHARE_PATH`, `SMB_USER`, `SMB_PASSWORD` - SMB network storage credentials

5. Comment out line 63 in for DNS challenge (production environments)

6. Configure Cloudflare tunnel application routes via cloudflare-tunneled

### Deployment

Run the automated setup script:
```bash
sudo ./setup.sh
```

This script will:
- Verify all prerequisites and configuration
- Install and configure Tailscale for VPN access
- Install Docker and Docker Engine
- Initialize and start all services

## Architecture

- **Traefik** listens on HTTP (80) and HTTPS (443) ports
- HTTP traffic automatically redirects to HTTPS
- Let's Encrypt certificates are stored in `cert/acme.json`
- Services are accessed via `service-name.home.{DOMAIN_NAME}`
- Dashboard accessible at `dashboard.home.{DOMAIN_NAME}` with basic auth
- Any service can be configured for secure public access

## Environment Variables

See `example.env` for all configurable options including:
- Cloudflare API credentials
- Traefik dashboard authentication
- Domain and email configuration
- Tailscale VPN settings
- SMB network storage credentials

## Network Configuration

All services use the `proxy` Docker network for inter-container communication. Services must have the following labels to be accessible through Traefik:
- `traefik.enable=true`
- Appropriate routing rules for the service

## Security Considerations

- Traefik dashboard requires basic authentication
- Docker socket is mounted read-only for security
- ACME staging environment is enabled by default for testing (uncomment production ACME URL when ready)
- All traffic redirects to HTTPS with automatic SSL/TLS termination

## Monitoring

- Traefik exposes Prometheus metrics on the configured metrics endpoint
- Beszel provides system-level monitoring and resource tracking
- Portainer offers a comprehensive Docker management interface
- Access logs are enabled on Traefik for debugging

## License

See LICENSE file for details.
