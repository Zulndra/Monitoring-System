
# Monitoring System

A full monitoring system using Docker, Prometheus, Grafana, and SNMP Exporter.  
Everything runs directly with Docker Compose.

---

## Prerequisites
- Latest Ubuntu server
- User with sudo privileges
- Active internet connection

---

## Install Git
```bash
sudo apt install git -y
```

---

## Install Docker & Docker Compose
```bash
sudo apt update && sudo apt upgrade -y && sudo apt install -y apt-transport-https ca-certificates curl software-properties-common lsb-release gnupg && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io && sudo usermod -aG docker $USER && newgrp docker && sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose && docker --version && docker compose version && docker run hello-world
```

---

## Clone Repository
```bash
git clone https://github.com/Zulndra/Monitoring-System
cd Monitoring-System
```

---

## Start Docker Compose
```bash
docker compose up --build -d
```

---

## Check Containers
```bash
docker ps
```
All containers (`prometheus`, `snmp-exporter`, `grafana`, etc.) should be **running**.

---

## Open Required Ports
- TCP: `9116`, `9090`, `9100`, `3000`

---

## Access Grafana
Open in browser:
```
http://<Public IP>:3000
```

---

## Import Grafana Dashboard
1. Go to Grafana → Menu `Dashboard → Import`  
2. Choose the `.json` file from `grafana/templates` folder  
3. Select Prometheus as the data source  
4. Click **Import** to load the dashboard

---

## Notes
- If port conflicts occur, make sure no other process is using the host ports.  
- All configurations for Prometheus, SNMP Exporter, and Grafana are already included in the repository.  

With these steps, the monitoring system is **ready to use immediately** without any additional configuration.
