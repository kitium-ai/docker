#!/bin/bash

# ============================================================================
# Health Check Script for all services
# Usage: ./scripts/health-check.sh
# ============================================================================

set -e

echo "=========================================="
echo "Service Health Check"
echo "=========================================="

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED=0

# Function to check service health
check_service() {
    local service=$1
    local port=$2
    local path=${3:-/health}

    echo -n "Checking $service..."

    if docker-compose exec -T "$service" curl -sf "http://localhost:$port$path" > /dev/null 2>&1; then
        echo -e " ${GREEN}✓ Healthy${NC}"
    else
        echo -e " ${RED}✗ Unhealthy${NC}"
        FAILED=$((FAILED + 1))
    fi
}

# Function to check database connectivity
check_database() {
    echo -n "Checking database connectivity..."

    if docker-compose exec -T postgres pg_isready -U "${POSTGRES_USER:-kitium}" > /dev/null 2>&1; then
        echo -e " ${GREEN}✓ Connected${NC}"
    else
        echo -e " ${RED}✗ Not connected${NC}"
        FAILED=$((FAILED + 1))
    fi
}

# Function to check Redis connectivity
check_redis() {
    echo -n "Checking Redis connectivity..."

    if docker-compose exec -T redis redis-cli --raw incr ping > /dev/null 2>&1; then
        echo -e " ${GREEN}✓ Connected${NC}"
    else
        echo -e " ${RED}✗ Not connected${NC}"
        FAILED=$((FAILED + 1))
    fi
}

# Function to show container status
show_status() {
    echo ""
    echo "Container Status:"
    docker-compose ps
}

# Run checks
check_service "api" "3000" "/health"
check_service "web" "3001" "/"
check_database
check_redis

show_status

echo ""
echo "=========================================="

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All services are healthy${NC}"
    echo "=========================================="
    exit 0
else
    echo -e "${RED}$FAILED service(s) are unhealthy${NC}"
    echo "=========================================="
    exit 1
fi
