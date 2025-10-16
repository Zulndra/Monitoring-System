#!/bin/bash

# Health Check Script for Monitoring System
# Usage: ./health-check.sh

set -e

echo "=========================================="
echo "🏥 Monitoring System Health Check"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if docker-compose exists
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not installed${NC}"
    exit 1
fi

echo "1. Container Status"
echo "-------------------"
docker compose ps
echo ""

# Count running containers
RUNNING=$(docker compose ps --format json | grep -c '"State":"running"' || echo "0")
TOTAL=$(docker compose ps --format json | wc -l)

if [ "$RUNNING" -gt 0 ]; then
    echo -e "${GREEN}✅ $RUNNING/$TOTAL containers running${NC}"
else
    echo -e "${RED}❌ No containers running!${NC}"
    exit 1
fi

echo ""
echo "2. Service Endpoints"
echo "--------------------"

# Check Grafana
GRAFANA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health || echo "000")
if [ "$GRAFANA_STATUS" = "200" ]; then
    echo -e "Grafana (3000):       ${GREEN}✅ HTTP $GRAFANA_STATUS${NC}"
else
    echo -e "Grafana (3000):       ${RED}❌ HTTP $GRAFANA_STATUS${NC}"
fi

# Check Prometheus
PROM_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9090/-/healthy || echo "000")
if [ "$PROM_STATUS" = "200" ]; then
    echo -e "Prometheus (9090):    ${GREEN}✅ HTTP $PROM_STATUS${NC}"
else
    echo -e "Prometheus (9090):    ${RED}❌ HTTP $PROM_STATUS${NC}"
fi

# Check SNMP Exporter
SNMP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9116/metrics || echo "000")
if [ "$SNMP_STATUS" = "200" ]; then
    echo -e "SNMP Exporter (9116): ${GREEN}✅ HTTP $SNMP_STATUS${NC}"
else
    echo -e "SNMP Exporter (9116): ${RED}❌ HTTP $SNMP_STATUS${NC}"
fi

echo ""
echo "3. Error Check"
echo "--------------"
ERROR_COUNT=$(docker compose logs --tail=100 2>&1 | grep -iE "error|fatal|panic" | grep -v "level=info" | wc -l || echo "0")

if [ "$ERROR_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $ERROR_COUNT error messages in last 100 log lines${NC}"
    echo ""
    echo "Recent errors:"
    docker compose logs --tail=100 2>&1 | grep -iE "error|fatal|panic" | tail -5
else
    echo -e "${GREEN}✅ No critical errors found${NC}"
fi

echo ""
echo "4. Resource Usage"
echo "-----------------"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo ""
echo "5. Disk Usage"
echo "-------------"
df -h | grep -E "Filesystem|/dev/"

echo ""
echo "=========================================="
echo "✅ Health check completed!"
echo "=========================================="
