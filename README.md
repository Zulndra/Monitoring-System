# Monitoring System

A full monitoring system using Docker, Prometheus, Grafana, and SNMP Exporter. Everything runs directly with Docker Compose.

## Prerequisites

* Latest Ubuntu server
* User with sudo privileges
* Active internet connection

## Install Git

```bash
sudo apt install git -y
```

## Install Docker & Docker Compose

```bash
sudo apt update && sudo apt upgrade -y && sudo apt install -y apt-transport-https ca-certificates curl software-properties-common lsb-release gnupg && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io && sudo usermod -aG docker $USER && newgrp docker && sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose && docker --version && docker compose version && docker run hello-world
```

## Clone Repository

```bash
git clone https://github.com/Zulndra/Monitoring-System
cd Monitoring-System
```

## Start Docker Compose

```bash
docker compose up --build -d
```

## Check Containers

```bash
docker ps
```

All containers (`prometheus`, `snmp-exporter`, `grafana`, etc.) should be running.

## Open Required Ports

* TCP: `9116`, `9090`, `9100`, `3000`

## Access Grafana

Open in browser:

```
http://<Public IP>:3000
```

## Import Grafana Dashboard

1. Go to Grafana → Menu `Dashboard → Import`
2. Choose the `.json` file from `grafana/templates` folder
3. Select Prometheus as the data source
4. Click Import to load the dashboard

## Automatic Deployment with GitHub Actions

This repository includes automatic deployment using GitHub Actions. Every time you push to the `main` branch, the system will automatically deploy to your server.

### How It Works

The GitHub Actions workflow (`.github/workflows/deploy.yml`) will:
1. Checkout the latest code from repository
2. Connect to your server via SSH
3. Pull the latest changes
4. Update Docker images
5. Restart containers with zero downtime

### Setup Auto Deployment

#### 1. Generate SSH Key Pair (if you don't have one)

On your local machine:

```bash
ssh-keygen -t rsa -b 4096 -C "github-actions"
```

Press Enter to save in default location. This will create:
- `~/.ssh/id_rsa` (private key)
- `~/.ssh/id_rsa.pub` (public key)

#### 2. Copy Public Key to Server

```bash
ssh-copy-id ubuntu@<your-server-ip>
```

Or manually:

```bash
cat ~/.ssh/id_rsa.pub
```

Then add it to `~/.ssh/authorized_keys` on your server.

#### 3. Add GitHub Secrets

Go to your GitHub repository:

**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these three secrets:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `HOST` | `98.87.83.12` | Your server IP address |
| `USERNAME` | `ubuntu` | SSH username |
| `SSH_KEY` | Contents of `~/.ssh/id_rsa` | Your private SSH key (entire content including BEGIN and END lines) |

To get your private key content:

```bash
cat ~/.ssh/id_rsa
```

Copy everything from `-----BEGIN RSA PRIVATE KEY-----` to `-----END RSA PRIVATE KEY-----` (including those lines).

#### 4. Verify Workflow File

Make sure `.github/workflows/deploy.yml` exists in your repository with this content:

```yaml
name: Auto Deploy to Server
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Deploy to Server via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /root/monitoring 
            git pull origin main
            docker compose pull
            docker compose up -d --build
```

**Note:** Make sure to update the path `/root/monitoring` to match where your project is located on the server.

#### 5. Test the Deployment

1. Make any small change to your repository
2. Commit and push to `main` branch:

```bash
git add .
git commit -m "test auto deployment"
git push origin main
```

3. Go to **Actions** tab in your GitHub repository
4. You should see the workflow running
5. Click on it to see the deployment progress

### Troubleshooting

**If deployment fails:**

1. Check the Actions logs in GitHub for error messages
2. Verify all secrets are correctly set
3. Ensure the project path in `deploy.yml` matches your server
4. Make sure Docker is running on your server
5. Verify SSH access manually:

```bash
ssh ubuntu@<your-server-ip>
```

**Common Issues:**

- **Permission denied**: Check if public key is in `~/.ssh/authorized_keys` on server
- **Git pull fails**: Make sure the repository is cloned on the server first
- **Docker command not found**: User may need to be in docker group: `sudo usermod -aG docker ubuntu`

## Notes

* If port conflicts occur, make sure no other process is using the host ports.
* All configurations for Prometheus, SNMP Exporter, and Grafana are already included in the repository.
* Auto deployment only triggers on pushes to the `main` branch.

With these steps, the monitoring system is ready to use immediately without any additional configuration, and will automatically update whenever you push changes to GitHub!
