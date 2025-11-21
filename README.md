# @kitiumai/docker

Enterprise-ready Docker package for Kitium AI services with production-grade configurations, multi-stage builds, Docker Compose orchestration, and complete networking setup.

## Features

✅ **Multi-stage Builds** - Optimized Docker images with minimal production footprint
✅ **Docker Compose** - Complete local development and production environments
✅ **Custom Networking** - Isolated bridge network for inter-service communication
✅ **Volume Management** - Persistent data storage and log management
✅ **Security Best Practices** - Non-root users, health checks, resource limits
✅ **Production Ready** - Environment-specific configurations and scaling options
✅ **Comprehensive Monitoring** - Health checks, logging, and service status
✅ **Database Integration** - PostgreSQL with initialization scripts and backups
✅ **Caching Layer** - Redis for session and cache management

## Project Structure

```
.
├── services/
│   ├── api/                    # Node.js Express API service
│   │   ├── Dockerfile          # Multi-stage build
│   │   ├── src/
│   │   │   └── index.ts        # API entry point
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── .dockerignore
│   └── web/                    # Next.js web service
│       ├── Dockerfile          # Multi-stage build
│       ├── package.json
│       ├── next.config.js
│       └── .dockerignore
├── scripts/
│   ├── init-db.sql            # Database initialization
│   ├── backup-database.sh     # Backup script
│   ├── restore-database.sh    # Restore script
│   └── health-check.sh        # Health monitoring
├── volumes/                   # Data persistence
│   ├── postgres_data/
│   ├── redis_data/
│   ├── api_logs/
│   └── web_logs/
├── docker-compose.yml         # Base configuration
├── docker-compose.dev.yml     # Development overrides
├── docker-compose.prod.yml    # Production overrides
├── .env.example               # Environment template
├── .dockerignore              # Docker build exclusions
└── package.json               # NPM scripts
```

## Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/kitium-ai/docker.git
   cd docker
   ```

2. **Create environment file**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Build and start services** (Development)
   ```bash
   npm run dev:build
   npm run dev
   ```

4. **Verify services are running**
   ```bash
   npm run healthcheck
   ```

## Available Commands

### Development Environment

```bash
# Start services in development mode
npm run dev

# Build all services
npm run dev:build

# Stop all services
npm run dev:down

# View real-time logs
npm run logs

# Run tests
npm run test

# Run linter
npm run lint
```

### Production Environment

```bash
# Start services in production mode
npm run prod

# Build for production
npm run prod:build

# Stop production services
npm run prod:down

# Check health of all services
npm run healthcheck

# Clean up containers and volumes
npm run clean
```

### Database Operations

```bash
# Backup database
./scripts/backup-database.sh

# Restore from backup
./scripts/restore-database.sh backups/kitium_db_backup_*.sql.gz

# Health check all services
./scripts/health-check.sh
```

## Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```env
# Node.js Environment
NODE_ENV=development
LOG_LEVEL=info

# Database
POSTGRES_USER=kitium
POSTGRES_PASSWORD=secure_password
POSTGRES_DB=kitium_dev
POSTGRES_PORT=5432

# Redis
REDIS_PASSWORD=redis_password
REDIS_PORT=6379

# API Service
API_PORT=3000
CORS_ORIGIN=*

# Web Service
WEB_PORT=3001
NEXT_PUBLIC_API_URL=http://localhost:3000
```

### Docker Compose Overrides

- **docker-compose.yml** - Base configuration with all services
- **docker-compose.dev.yml** - Development overrides (volume mounts, debug logging)
- **docker-compose.prod.yml** - Production overrides (resource limits, restart policies)

### Multi-stage Docker Build Targets

Each service Dockerfile includes multiple build targets:

```bash
# Development target (with hot reload)
docker build --target development .

# Production target (minimal image)
docker build --target production .
```

## Services

### API Service (Node.js/Express)

- **Port**: 3000
- **Health Check**: `GET /health`
- **Endpoints**:
  - `GET /version` - Service version
  - `GET /api/v1/status` - API status

### Web Service (Next.js)

- **Port**: 3001
- **Health Check**: `GET /`
- **Features**: Server-side rendering, static generation

### PostgreSQL Database

- **Port**: 5432
- **Version**: 15-Alpine
- **Database**: kitium_dev
- **Initialization**: Automatic schema and tables creation
- **Persistence**: Named volume `postgres_data`

### Redis Cache

- **Port**: 6379
- **Version**: 7-Alpine
- **Password**: Configured via `REDIS_PASSWORD`
- **Persistence**: AOF enabled for data durability

## Docker Networking

All services communicate via a custom bridge network (`kitium-network`):

```
                    ┌─────────────────┐
                    │   kitium-web    │
                    │   (3001:3001)   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   kitium-api    │
                    │   (3000:3000)   │
                    └────┬────────┬───┘
                         │        │
         ┌───────────────┘        └──────────────┐
         │                                       │
    ┌────▼─────────┐              ┌──────────────▼──┐
    │   postgres   │              │     redis      │
    │  (5432:5432) │              │  (6379:6379)  │
    └──────────────┘              └────────────────┘

Network: kitium-network (172.20.0.0/16)
```

### Service Hostnames

Services can communicate using hostnames:
- `api:3000` - API service
- `web:3001` - Web service
- `postgres:5432` - PostgreSQL
- `redis:6379` - Redis

## Volume Management

### Named Volumes

| Volume | Mount Point | Purpose |
|--------|------------|---------|
| `postgres_data` | `/var/lib/postgresql/data` | PostgreSQL database storage |
| `redis_data` | `/data` | Redis persistence |
| `api_logs` | `/app/logs` | API service logs |
| `web_logs` | `/app/.next/logs` | Next.js logs |

### Volume Locations

All volumes are stored in the `./volumes/` directory on the host:

```
volumes/
├── postgres_data/      # PostgreSQL data files
├── redis_data/        # Redis dump files
├── api_logs/          # API application logs
└── web_logs/          # Web application logs
```

## Security

### Best Practices Implemented

1. **Non-root Users** - All services run with non-root user (uid: 1000)
2. **Read-only Filesystems** - Where applicable
3. **Resource Limits** - CPU and memory constraints
4. **Health Checks** - Automated service health verification
5. **Network Isolation** - Services on custom bridge network
6. **Secrets Management** - Environment-based configuration
7. **Security Headers** - Helmet.js for HTTP headers
8. **CORS Configuration** - Configurable CORS policies

### Security Scanning

```bash
# Scan for vulnerabilities in dependencies
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image kitium-api:latest
```

## Monitoring and Logging

### Service Status

```bash
# View all containers
docker-compose ps

# View service logs
docker-compose logs -f api
docker-compose logs -f web
docker-compose logs -f postgres

# Filter logs by timestamp
docker-compose logs --since 2024-01-01 api
```

### Health Checks

Each service includes automated health checks:

```bash
# Run comprehensive health check
npm run healthcheck

# Manual API health check
curl http://localhost:3000/health

# Manual web health check
curl http://localhost:3001
```

### Performance Monitoring

```bash
# View resource usage
docker stats

# View detailed service stats
docker-compose stats
```

## Database Management

### Initialize Database

```bash
# Run initialization script automatically on startup
docker-compose up postgres

# Manual initialization
docker-compose exec postgres psql -U kitium -d kitium_dev -f /docker-entrypoint-initdb.d/init.sql
```

### Backup and Restore

```bash
# Create backup
./scripts/backup-database.sh

# Restore from backup
./scripts/restore-database.sh backups/kitium_db_backup_20240101_120000.sql.gz

# List backups
ls -lh backups/
```

### Database Access

```bash
# Connect to database
docker-compose exec postgres psql -U kitium -d kitium_dev

# Execute SQL query
docker-compose exec postgres psql -U kitium -d kitium_dev -c "SELECT version();"
```

## Performance Optimization

### Multi-stage Build Benefits

- **Development**: Full features with hot reload
- **Production**: Minimal image size, optimized dependencies
- **Layer Caching**: Faster builds by caching dependencies

### Resource Limits

Configure in `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 1024M
    reservations:
      cpus: '0.5'
      memory: 512M
```

### Volume Mount Caching

Development volumes use `cached` option for performance:

```yaml
volumes:
  - ./services/api/src:/app/src:cached
```

## Troubleshooting

### Services Won't Start

```bash
# Check logs for errors
docker-compose logs api
docker-compose logs web
docker-compose logs postgres

# Validate configuration
npm run validate
```

### Database Connection Issues

```bash
# Check database health
docker-compose exec postgres pg_isready -U kitium

# Check network connectivity
docker-compose exec api ping postgres
docker-compose exec api curl http://redis:6379
```

### High Memory Usage

```bash
# Check container resource usage
docker stats

# Reduce limits in .env and docker-compose override
export POSTGRES_MEMORY=256M
```

### Port Already in Use

```bash
# Change port in .env
API_PORT=3002
WEB_PORT=3003

# Or kill the process using the port
lsof -i :3000
kill -9 <PID>
```

## Production Deployment

### Pre-deployment Checklist

- [ ] All environment variables configured
- [ ] Database backups tested
- [ ] SSL/TLS certificates obtained
- [ ] Resource limits appropriate for server
- [ ] Health checks passing consistently
- [ ] Load balancer configured (if applicable)

### Docker Swarm Deployment

```bash
# Initialize swarm (single node)
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml kitium

# View services
docker service ls

# Scale services
docker service scale kitium_api=3
```

### Kubernetes Deployment

Convert Docker Compose to Kubernetes manifests:

```bash
# Install Kompose
curl -L https://github.com/kubernetes/kompose/releases/download/v1.28.0/kompose-linux-amd64 -o kompose
chmod +x kompose

# Convert
./kompose convert -f docker-compose.yml -o k8s/
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with all environments
5. Submit a pull request

## License

MIT License - See LICENSE file for details

## Support

- **Issues**: https://github.com/kitium-ai/docker/issues
- **Discussions**: https://github.com/kitium-ai/docker/discussions
- **Email**: dev@kitium.ai

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and breaking changes.

---

**Last Updated**: 2024-01-21
**Version**: 1.0.0
**Maintainer**: Kitium AI Team
