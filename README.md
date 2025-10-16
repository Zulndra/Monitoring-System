# Monitoring System

A comprehensive monitoring system using Docker, Prometheus, Grafana, and SNMP Exporter with automated CI/CD deployment.

## Quick Start

### Prerequisites

- Ubuntu Server
- Docker & Docker Compose installed
- Git installed

### Installation
```bash
# Install Docker & Docker Compose
sudo apt update && sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
newgrp docker

# Clone repository
git clone https://github.com/Zulndra/Monitoring-System.git
cd Monitoring-System

# Start services
docker compose up -d

# Check status
docker compose ps
```

### Access Services

- **Grafana**: `http://<server-ip>:3000` (default: admin/admin)
- **Prometheus**: `http://<server-ip>:9090`
- **SNMP Exporter**: `http://<server-ip>:9116`

**Required Ports:** 3000, 9090, 9116

---

## Automated Deployment

This project uses **GitHub Actions** for automated deployment with two environments:

### How It Works
```
Developer → Push to 'staged' branch → Auto deploy to Staging Server
                                              ↓
                                         Test & Verify
                                              ↓
                                    Create Pull Request (PR)
                                              ↓
                              Merge PR to 'main' → Auto deploy to Production Server
```

### Workflow Files

- `.github/workflows/deploy-staging.yml` - Deploys to staging server when you push to `staged` branch
- `.github/workflows/deploy-production.yml` - Deploys to production server when you push/merge to `main` branch

### What Happens on Deployment

1. GitHub Actions connects to your server via SSH
2. Pulls latest code from repository
3. Creates backup (production only)
4. Restarts Docker containers
5. Runs health checks (Grafana, Prometheus, SNMP Exporter)
6. Reports deployment status

---

## Setup Auto Deployment

### 1. Prepare Servers

**On both staging and production servers:**
```bash
# Clone repository
git clone https://github.com/Zulndra/Monitoring-System.git /home/ubuntu/Monitoring-System
cd /home/ubuntu/Monitoring-System

# Setup permissions
sudo chown -R ubuntu:ubuntu /home/ubuntu/Monitoring-System
sudo usermod -aG docker ubuntu

# For staging server
git checkout staged

# For production server
git checkout main

# Start services
docker compose up -d
```

### 2. Add GitHub Secrets

Go to **GitHub Repository → Settings → Secrets and variables → Actions**

Add these secrets:

**For Staging:**
- `STAGING_SSH_KEY` - Your SSH private key (.pem file content)
- `STAGING_HOST` - Staging server IP (e.g., 98.87.60.46)
- `STAGING_USERNAME` - SSH username (usually `ubuntu`)
- `STAGING_PROJECT_PATH` - `/home/ubuntu/Monitoring-System`

**For Production:**
- `SSH_KEY` - Your SSH private key (.pem file content)
- `HOST` - Production server IP (e.g., 98.87.83.12)
- `USERNAME` - SSH username (usually `ubuntu`)
- `PROJECT_PATH` - `/home/ubuntu/Monitoring-System`

**Get your SSH key content:**
```bash
cat /path/to/your-key.pem
```
Copy everything including `-----BEGIN` and `-----END` lines.

---

## Daily Usage

### Deploy to Staging
```bash
# Work on staging branch
git checkout staged

# Make changes
# ... edit files ...

# Commit and push (auto deploys to staging)
git add .
git commit -m "feat: add new feature"
git push origin staged
```

**Result:** Automatically deploys to staging server. Check **Actions** tab to monitor progress.

### Deploy to Production

After testing in staging:
```bash
# Create Pull Request
gh pr create --base main --head staged --title "Deploy to Production"

# Or via GitHub web: Pull requests → New pull request → base: main ← compare: staged

# Review and merge the PR
```

**Result:** Automatically deploys to production server.

---

## Health Check

Run manual health check:
```bash
./health-check.sh
```

Or check individual services:
```bash
# Grafana
curl http://localhost:3000/api/health

# Prometheus
curl http://localhost:9090/-/healthy

# SNMP Exporter
curl http://localhost:9116/metrics
```

---

## Troubleshooting

### Deployment Failed

Check **Actions** tab in GitHub for error logs.

**Common fixes:**
```bash
# SSH to server
ssh ubuntu@<server-ip>

# Fix ownership
sudo chown -R ubuntu:ubuntu /home/ubuntu/Monitoring-System

# Fix docker permission
sudo usermod -aG docker ubuntu
exit
# Login again

# Fix git permission
git config --global --add safe.directory /home/ubuntu/Monitoring-System
```

### Services Not Running
```bash
# Check status
docker compose ps

# View logs
docker compose logs -f

# Restart
docker compose down
docker compose up -d
```

---

## Useful Commands
```bash
# Docker
docker compose up -d          # Start services
docker compose down           # Stop services
docker compose ps             # Check status
docker compose logs -f        # View logs

# Git
git checkout staged           # Switch to staging
git checkout main             # Switch to production
git pull origin staged        # Update staging
git pull origin main          # Update production

# Health check
./health-check.sh             # Run health check
docker stats                  # Resource usage
```

---

## Project Structure
```
Monitoring-System/
├── .github/workflows/        # GitHub Actions workflows
├── prometheus/               # Prometheus configuration
├── grafana/                  # Grafana dashboards
├── snmp-exporter/           # SNMP Exporter config
├── docker-compose.yml       # Docker services
└── health-check.sh          # Health check script
```

---

## Summary

1. **Clone** the repository
2. **Setup** GitHub Secrets for your servers
3. **Push to `staged`** branch for automatic deployment to staging
4. **Create PR to `main`** for automatic deployment to production
5. **Monitor** via GitHub Actions and Grafana dashboards

Your monitoring system with automated deployment is ready.
