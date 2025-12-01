# Changelog

All notable changes to @kitiumai/docker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.0.0] - 2025-12-01

### Added
- Observability stack with Vector, OpenTelemetry Collector, Prometheus, Grafana, and cAdvisor via docker-compose overlay
- Supply-chain tooling: Syft SBOM generation, Cosign signing scripts, and CI workflow for lint/test/scan
- Secrets overlay using Docker secrets and Vault dev server
- Database lifecycle tooling for WAL archiving, migration runner, and redacted seeds
- Kubernetes Kustomize bases with dev/stage/prod overlays plus Helm chart
- Developer ergonomics: Traefik HTTPS dev proxy and VS Code devcontainer

### Changed
- Dockerfile template now supports configurable base images and distroless runtime target for hardened builds
- README expanded with observability, security, Kubernetes/Helm, and compliance workflows

### Deprecated
- None

### Removed
- None

### Fixed
- None

### Security
- None

## [1.0.0] - 2024-01-21

### Added

#### Core Features
- **Docker Compose Orchestration** - Complete development and production configurations
- **Multi-stage Dockerfiles** - Optimized builds for API and Web services
- **Custom Docker Network** - Isolated bridge network (kitium-network) for service communication
- **Volume Management** - Named volumes for PostgreSQL, Redis, logs persistence

#### Services
- **API Service** - Node.js/Express with TypeScript support
- **Web Service** - Next.js with server-side rendering
- **PostgreSQL Database** - Version 15-Alpine with automatic initialization
- **Redis Cache** - Version 7-Alpine with persistence and password protection

#### Security Features
- Non-root user execution (uid: 1000)
- Helmet.js integration for HTTP headers
- CORS configuration support
- Health checks for all services
- Resource limits (CPU/memory)
- Security context configuration
- Secrets management via environment variables

#### Docker Configuration
- `docker-compose.yml` - Base configuration
- `docker-compose.dev.yml` - Development overrides with hot reload
- `docker-compose.prod.yml` - Production overrides with scaling
- `.dockerignore` - Build context optimization
- `Dockerfile` for each service with proper build targets

#### Database Features
- PostgreSQL initialization script with schema creation
- UUID and pgcrypto extensions
- Audit logging table structure
- User sessions management
- Automated index creation

#### Scripting
- `backup-database.sh` - PostgreSQL backup automation
- `restore-database.sh` - Database restoration from backup
- `health-check.sh` - Comprehensive service health monitoring

#### NPM Scripts
- `dev` - Start development environment
- `dev:build` - Build for development
- `dev:down` - Stop development environment
- `prod` - Start production environment
- `prod:build` - Build for production
- `prod:down` - Stop production environment
- `logs` - View real-time logs
- `validate` - Validate Docker Compose configuration
- `clean` - Remove containers and volumes
- `healthcheck` - Check service health
- `test` - Run tests
- `lint` - Run linter

#### Documentation
- **README.md** - Comprehensive guide with quick start
- **SECURITY.md** - Security best practices and compliance guidelines
- **CONTRIBUTING.md** - Contribution guidelines
- **CHANGELOG.md** - Version history (this file)

#### Configuration Files
- `.env.example` - Environment configuration template
- `.gitignore` - Git exclusions
- `package.json` - NPM metadata and scripts

### Key Features

✅ **Enterprise Ready**
- Production-grade configurations
- Proper resource management
- Health monitoring
- Backup and restore procedures

✅ **Developer Friendly**
- Easy local development setup
- Hot reload support
- Comprehensive documentation
- Health check monitoring

✅ **Security First**
- Non-root containers
- Network isolation
- Secrets management
- Regular updates support

✅ **Scalable Architecture**
- Multi-stage builds for efficiency
- Custom networking for service discovery
- Volume persistence for data durability
- Resource limits for constraint management

### Technical Specifications

#### Container Details
- **Base Image**: node:18-alpine (all services)
- **Database**: postgres:15-alpine
- **Cache**: redis:7-alpine
- **Network**: Custom bridge (kitium-network, 172.20.0.0/16)

#### Service Ports
- API: 3000 (configurable)
- Web: 3001 (configurable)
- PostgreSQL: 5432 (configurable)
- Redis: 6379 (configurable)

#### Health Check Configuration
- Interval: 30 seconds (default)
- Timeout: 10 seconds
- Retries: 3
- Start period: 5-20 seconds

#### Resource Limits
- API: CPU 2, Memory 1GB (limit), 0.5/512MB (reservation)
- Web: CPU 2, Memory 512MB (limit), 0.5/256MB (reservation)
- PostgreSQL: CPU 1, Memory 512MB (limit), 0.5/256MB (reservation)
- Redis: CPU 0.5, Memory 256MB (limit), 0.25/128MB (reservation)

### Browser/Platform Support

- **Docker Engine**: 20.10+
- **Docker Compose**: 2.0+
- **Operating Systems**: Linux, macOS, Windows (with WSL2)
- **Node.js**: 18.x LTS (for local development)

### Known Issues

None reported in initial release.

### Migration Guide

First installation - no migration needed.

### Contributors

- Kitium AI Team - Initial implementation

---

## Version Format

Versions follow [Semantic Versioning](https://semver.org/):
- MAJOR: Incompatible API changes
- MINOR: New backwards-compatible functionality
- PATCH: Backwards-compatible bug fixes

## Future Roadmap

### Planned for v1.1.0
- [ ] Kubernetes manifests (via Kompose)
- [ ] Docker Swarm example deployment
- [ ] Prometheus monitoring integration
- [ ] ELK stack logging integration

### Planned for v2.0.0
- [ ] Microservices examples
- [ ] API Gateway (Traefik)
- [ ] SSL/TLS configuration
- [ ] CI/CD pipeline examples
- [ ] Load balancing setup

### Long-term Goals
- [ ] Helm charts for Kubernetes
- [ ] Terraform modules for cloud deployment
- [ ] Advanced monitoring dashboards
- [ ] Advanced security hardening guides
- [ ] GPU support for ML services

---

**Last Updated**: 2024-01-21
**Maintainer**: Kitium AI Team
**License**: MIT
