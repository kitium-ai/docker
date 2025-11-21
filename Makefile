# ============================================================================
# Makefile for @kitiumai/docker
# Usage: make [target]
# ============================================================================

.PHONY: help dev dev-build dev-down prod prod-build prod-down logs \
        health clean validate backup restore db-connect db-shell \
        test lint format install remove-volumes

# Default target
.DEFAULT_GOAL := help

# Variables
DOCKER_COMPOSE := docker-compose
DOCKER := docker
COMPOSE_DEV := -f docker-compose.yml -f docker-compose.dev.yml
COMPOSE_PROD := -f docker-compose.yml -f docker-compose.prod.yml

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)@kitiumai/docker - Make targets:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

# ============================================================================
# Development Environment
# ============================================================================

dev: ## Start development environment
	@echo "$(BLUE)Starting development environment...$(NC)"
	$(DOCKER_COMPOSE) $(COMPOSE_DEV) up

dev-build: ## Build development environment
	@echo "$(BLUE)Building development environment...$(NC)"
	$(DOCKER_COMPOSE) $(COMPOSE_DEV) build

dev-down: ## Stop development environment
	@echo "$(BLUE)Stopping development environment...$(NC)"
	$(DOCKER_COMPOSE) $(COMPOSE_DEV) down

# ============================================================================
# Production Environment
# ============================================================================

prod: ## Start production environment
	@echo "$(BLUE)Starting production environment...$(NC)"
	$(DOCKER_COMPOSE) $(COMPOSE_PROD) up -d

prod-build: ## Build production environment
	@echo "$(BLUE)Building production environment...$(NC)"
	$(DOCKER_COMPOSE) $(COMPOSE_PROD) build

prod-down: ## Stop production environment
	@echo "$(BLUE)Stopping production environment...$(NC)"
	$(DOCKER_COMPOSE) $(COMPOSE_PROD) down

# ============================================================================
# Monitoring and Debugging
# ============================================================================

logs: ## Show real-time logs
	$(DOCKER_COMPOSE) $(COMPOSE_DEV) logs -f

logs-api: ## Show API logs
	$(DOCKER_COMPOSE) $(COMPOSE_DEV) logs -f api

logs-web: ## Show Web logs
	$(DOCKER_COMPOSE) $(COMPOSE_DEV) logs -f web

logs-postgres: ## Show PostgreSQL logs
	$(DOCKER_COMPOSE) $(COMPOSE_DEV) logs -f postgres

health: ## Check service health
	@echo "$(BLUE)Checking service health...$(NC)"
	@./scripts/health-check.sh

ps: ## Show running containers
	$(DOCKER_COMPOSE) ps

# ============================================================================
# Database Operations
# ============================================================================

db-connect: ## Connect to database
	$(DOCKER_COMPOSE) exec postgres psql -U kitium -d kitium_dev

db-shell: ## Open database shell
	$(DOCKER_COMPOSE) exec postgres bash

db-backup: ## Backup database
	@echo "$(BLUE)Backing up database...$(NC)"
	@./scripts/backup-database.sh

db-restore: ## Restore database (specify BACKUP_FILE=path/to/backup.sql.gz)
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "$(RED)Error: BACKUP_FILE not specified$(NC)"; \
		echo "Usage: make db-restore BACKUP_FILE=backups/kitium_db_backup_*.sql.gz"; \
		exit 1; \
	fi
	@echo "$(BLUE)Restoring database from $(BACKUP_FILE)...$(NC)"
	@./scripts/restore-database.sh $(BACKUP_FILE)

# ============================================================================
# Testing and Linting
# ============================================================================

test: ## Run tests
	@echo "$(BLUE)Running tests...$(NC)"
	$(DOCKER_COMPOSE) run --rm api npm test

lint: ## Run linter
	@echo "$(BLUE)Running linter...$(NC)"
	$(DOCKER_COMPOSE) run --rm api npm run lint

format: ## Format code
	@echo "$(BLUE)Formatting code...$(NC)"
	$(DOCKER_COMPOSE) run --rm api npm run format

# ============================================================================
# Configuration and Validation
# ============================================================================

validate: ## Validate Docker Compose configuration
	@echo "$(BLUE)Validating Docker Compose configuration...$(NC)"
	$(DOCKER_COMPOSE) config > /dev/null && echo "$(GREEN)✓ Configuration is valid$(NC)"

env-setup: ## Setup environment file
	@if [ ! -f .env ]; then \
		echo "$(BLUE)Creating .env file...$(NC)"; \
		cp .env.example .env; \
		echo "$(GREEN)✓ .env file created$(NC)"; \
		echo "$(RED)Please edit .env with your configuration$(NC)"; \
	else \
		echo "$(RED)✗ .env file already exists$(NC)"; \
	fi

# ============================================================================
# Cleanup
# ============================================================================

clean: ## Remove containers and volumes (development)
	@echo "$(RED)Cleaning up development environment...$(NC)"
	$(DOCKER_COMPOSE) $(COMPOSE_DEV) down -v

clean-all: ## Remove all containers, images, and volumes
	@echo "$(RED)WARNING: This will remove all containers, images, and volumes$(NC)"
	@read -p "Are you sure? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		$(DOCKER_COMPOSE) $(COMPOSE_DEV) down -v; \
		$(DOCKER) rmi -f kitium-api kitium-web || true; \
		echo "$(GREEN)✓ Cleanup complete$(NC)"; \
	fi

remove-volumes: ## Remove data volumes
	@echo "$(RED)Removing data volumes...$(NC)"
	@rm -rf volumes/postgres_data volumes/redis_data
	@echo "$(GREEN)✓ Volumes removed$(NC)"

# ============================================================================
# Installation and Setup
# ============================================================================

install: ## Install dependencies
	@echo "$(BLUE)Installing dependencies...$(NC)"
	npm install
	$(DOCKER_COMPOSE) $(COMPOSE_DEV) build

# ============================================================================
# Docker Image Management
# ============================================================================

build-api: ## Build API image
	@echo "$(BLUE)Building API image...$(NC)"
	$(DOCKER) build -t kitium-api:latest ./services/api

build-web: ## Build Web image
	@echo "$(BLUE)Building Web image...$(NC)"
	$(DOCKER) build -t kitium-web:latest ./services/web

push-api: ## Push API image to registry (specify REGISTRY=your-registry)
	@if [ -z "$(REGISTRY)" ]; then \
		echo "$(RED)Error: REGISTRY not specified$(NC)"; \
		echo "Usage: make push-api REGISTRY=your-registry"; \
		exit 1; \
	fi
	@echo "$(BLUE)Pushing API image to $(REGISTRY)...$(NC)"
	$(DOCKER) tag kitium-api:latest $(REGISTRY)/kitium-api:latest
	$(DOCKER) push $(REGISTRY)/kitium-api:latest

push-web: ## Push Web image to registry (specify REGISTRY=your-registry)
	@if [ -z "$(REGISTRY)" ]; then \
		echo "$(RED)Error: REGISTRY not specified$(NC)"; \
		echo "Usage: make push-web REGISTRY=your-registry"; \
		exit 1; \
	fi
	@echo "$(BLUE)Pushing Web image to $(REGISTRY)...$(NC)"
	$(DOCKER) tag kitium-web:latest $(REGISTRY)/kitium-web:latest
	$(DOCKER) push $(REGISTRY)/kitium-web:latest

# ============================================================================
# Version and Info
# ============================================================================

version: ## Show version info
	@echo "$(BLUE)@kitiumai/docker - Information:$(NC)"
	@echo "  Version: $$(grep '\"version\"' package.json | grep -oP '\d+\.\d+\.\d+')"
	@echo "  Docker: $$(docker --version)"
	@echo "  Docker Compose: $$(docker-compose --version)"
	@echo "  Node: $$(node --version 2>/dev/null || echo 'not installed')"

.PHONY: version

# ============================================================================
# Utility Targets
# ============================================================================

shell-api: ## Open shell in API container
	$(DOCKER_COMPOSE) exec api sh

shell-web: ## Open shell in Web container
	$(DOCKER_COMPOSE) exec web sh

shell-postgres: ## Open shell in PostgreSQL container
	$(DOCKER_COMPOSE) exec postgres sh

redis-cli: ## Open Redis CLI
	$(DOCKER_COMPOSE) exec redis redis-cli

# ============================================================================
# Status Info
# ============================================================================

status: ## Show Docker and container status
	@echo "$(BLUE)System Status:$(NC)"
	@echo ""
	@echo "$(BLUE)Docker Daemon:$(NC)"
	@docker info | grep -E "Containers|Images|Storage"
	@echo ""
	@echo "$(BLUE)Running Containers:$(NC)"
	@$(DOCKER_COMPOSE) ps
	@echo ""
	@echo "$(BLUE)Resource Usage:$(NC)"
	@docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null || echo "No containers running"
