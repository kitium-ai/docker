# Docker Standardization Guide

This document outlines the standardized Docker setup for KitiumAI services and how to use it.

## What Was Standardized

### 1. ✅ Dockerfile Template (`Dockerfile.template`)

Located in: `tooling/docker/Dockerfile.template`

**Purpose**: Reusable multi-stage Docker template for all Node.js services

**Features**:
- Multi-stage builds (builder, production, development)
- Works with pnpm monorepo structure
- Supports different build targets via `BUILD_TARGET` arg
- Includes health checks
- Optimized for minimal production image size
- Development mode with hot reload
- Non-root user for security

**How to use**:
1. Copy to your service directory: `cp tooling/docker/Dockerfile.template apps/my-service/Dockerfile`
2. Customize the service name and entry point
3. Customize health check endpoint
4. Add to docker-compose.yml

### 2. ✅ Individual Service Dockerfiles

Created for:
- `apps/api/Dockerfile` - Express.js API service
- `apps/website/Dockerfile` - Next.js web application

**Key differences**:
- **API**: Standard Node.js app, health check at `/health`
- **Website**: Next.js specific setup, uses `pnpm start` in production

### 3. ✅ Centralized Environment Configuration (`.env.example`)

Located in: `tooling/docker/.env.example`

**Coverage**: 200+ environment variables organized by service:
- Environment & build config
- Database (PostgreSQL)
- Cache (Redis)
- API Service
- Web Service (Next.js)
- Email Service
- File Service (AWS S3)
- Search Service (Elasticsearch)
- Analytics Service
- Billing Service
- Monitoring & Logging
- Security (JWT, encryption)
- Feature Flags
- Development config

**How to use**:
1. Copy to root of tooling/docker: `cp .env.example .env`
2. Update all `change_me` values
3. Set appropriate values for your environment (dev/prod)
4. **IMPORTANT**: Never commit `.env` file with real secrets

### 4. ✅ Updated docker-compose.yml

Fixed build contexts:
- **Old**: `context: ./services/api` ❌
- **New**: `context: ../..` with `dockerfile: ./apps/api/Dockerfile` ✅

Fixed volume mounts:
- **Old**: `./services/api/src` ❌
- **New**: `../../../apps/api/src` ✅

Fixed web service:
- **Old**: `./services/web` ❌
- **New**: `../../../apps/website` ✅

### 5. ✅ Database Initialization (existing)

File: `tooling/docker/scripts/init-db.sql`

Already includes:
- PostgreSQL extensions
- User and session tables
- Audit logging tables
- Database functions and triggers
- Index creation for performance

### 6. ✅ Updated Documentation

Enhanced `tooling/docker/README.md` with:
- New project structure diagram
- Dockerfile strategy explanation
- How to create new service Dockerfiles
- Updated quick start instructions
- Environment variable documentation

## File Structure

```
tooling/docker/
├── Dockerfile.template              ⭐ New - Reusable template
├── .env.example                      ⭐ Updated - Comprehensive vars
├── docker-compose.yml                ⭐ Fixed - Correct paths
├── docker-compose.dev.yml            ✅ Existing
├── docker-compose.prod.yml           ✅ Existing
├── README.md                         ⭐ Updated - New sections
├── DOCKER_STANDARDIZATION_GUIDE.md   ⭐ New - This file
├── scripts/
│   ├── init-db.sql                   ✅ Existing
│   ├── backup-database.sh            ✅ Existing
│   ├── restore-database.sh           ✅ Existing
│   └── health-check.sh               ✅ Existing
└── volumes/                          ✅ For data persistence
    ├── postgres_data/
    ├── redis_data/
    ├── api_logs/
    └── web_logs/

apps/
├── api/
│   └── Dockerfile                    ⭐ New - Customized template
└── website/
    └── Dockerfile                    ⭐ New - Customized template
```

## Quick Start

### 1. Setup Environment

```bash
cd KitiumAI/tooling/docker
cp .env.example .env

# Edit .env and update:
# - POSTGRES_PASSWORD
# - REDIS_PASSWORD
# - JWT_SECRET
# - All AWS credentials (if using S3)
# - SMTP settings (if using email)
```

### 2. Build and Start Services

```bash
# Development mode (with hot reload)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build

# Production mode
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# View logs
docker-compose logs -f api
docker-compose logs -f web
```

### 3. Access Services

- **API**: http://localhost:3000
- **Web**: http://localhost:3001
- **Database**: localhost:5432 (user: kitium)
- **Redis**: localhost:6379

### 4. Check Health

```bash
npm run healthcheck

# Or manually
curl http://localhost:3000/health
curl http://localhost:3001
```

## Adding New Services

### Step 1: Create Service Directory

```bash
mkdir -p apps/my-service
```

### Step 2: Create Dockerfile

```bash
cp tooling/docker/Dockerfile.template apps/my-service/Dockerfile
```

### Step 3: Customize Dockerfile

Update in the Dockerfile:
```dockerfile
# Change service name in build stage
RUN pnpm --filter=@kitium-ai/my-service run build

# Change in production stage
COPY --from=builder /app/apps/my-service/dist ./apps/my-service/dist

# Change in development stage
CMD ["pnpm", "--filter=@kitium-ai/my-service", "dev"]

# Update entrypoint
CMD ["node", "apps/my-service/dist/index.js"]
```

### Step 4: Add to docker-compose.yml

```yaml
my-service:
  build:
    context: ../..
    dockerfile: ./apps/my-service/Dockerfile
    target: ${BUILD_TARGET:-production}
  container_name: kitium-my-service
  hostname: my-service
  restart: unless-stopped

  environment:
    NODE_ENV: ${NODE_ENV:-production}
    PORT: 3002

  ports:
    - "${MY_SERVICE_PORT:-3002}:3002"

  depends_on:
    postgres:
      condition: service_healthy
    redis:
      condition: service_healthy

  networks:
    - kitium-network

  env_file:
    - .env
```

### Step 5: Add Environment Variables

Add to `.env.example` and `.env`:
```env
MY_SERVICE_PORT=3002
MY_SERVICE_DATABASE_URL=postgresql://kitium:password@postgres:5432/my_service_db
```

## Best Practices

### 1. Environment Variables

✅ **DO**:
- Use `.env.example` as template
- Keep secrets in `.env` (never commit)
- Use `${VAR_NAME:-default}` for defaults
- Document each variable

❌ **DON'T**:
- Hardcode secrets in Dockerfile
- Commit `.env` with real values
- Use `latest` tag in production
- Run containers as root

### 2. Build Optimization

✅ **DO**:
- Use multi-stage builds (reduces image size)
- Cache dependencies properly
- Use `.dockerignore` to exclude files
- Use specific base image versions

❌ **DON'T**:
- Include unnecessary files in build context
- Run package manager cache in production
- Use `latest` base image tags
- Include dev dependencies in production

### 3. Security

✅ **DO**:
- Run as non-root user
- Use read-only root filesystem where possible
- Implement health checks
- Scan images for vulnerabilities
- Use secrets management

❌ **DON'T**:
- Run as root user
- Mount unnecessary volumes
- Expose sensitive environment variables
- Skip security scanning
- Use default passwords

### 4. Monitoring

✅ **DO**:
- Implement health checks
- Use structured logging
- Monitor resource usage
- Set up alerts

❌ **DON'T**:
- Log sensitive data
- Ignore health check failures
- Leave resource limits unlimited
- Skip log rotation

## Troubleshooting

### Build fails with "package not found"

**Cause**: Service package.json doesn't exist or service name is wrong

**Fix**:
```bash
# Check package.json exists
ls apps/my-service/package.json

# Check package.json has correct name
cat apps/my-service/package.json | grep '"name"'

# Update Dockerfile with correct name
```

### Container exits immediately

**Cause**: Missing entry point or incorrect command

**Fix**:
```bash
# Check build output
docker-compose logs api

# Verify entry point exists
docker-compose exec api ls -la /app/apps/api/dist/index.js

# Check for runtime errors
docker-compose exec api npm run build
```

### Database connection fails

**Cause**: PostgreSQL not started or credentials wrong

**Fix**:
```bash
# Verify PostgreSQL is running and healthy
docker-compose ps postgres

# Check environment variables
grep POSTGRES .env

# Test connection
docker-compose exec postgres psql -U kitium -d kitium_dev -c "SELECT 1"
```

### High memory usage

**Cause**: Resource limits too high or memory leak

**Fix**:
```bash
# Check memory usage
docker stats

# Reduce limits in .env
POSTGRES_MEMORY=256M

# Restart with limits
docker-compose down
docker-compose up -d
```

## Maintenance

### Regular Tasks

1. **Backup database** (weekly)
   ```bash
   ./scripts/backup-database.sh
   ```

2. **Check health** (daily)
   ```bash
   npm run healthcheck
   ```

3. **Update base images** (monthly)
   ```bash
   docker pull node:20-alpine
   docker-compose build --no-cache
   ```

4. **Scan for vulnerabilities** (monthly)
   ```bash
   docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
     aquasec/trivy image kitium-api:latest
   ```

## Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Node.js Docker Guide](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
- [pnpm Docker Support](https://pnpm.io/docker)

## Support

For questions or issues:
1. Check the README.md troubleshooting section
2. Review docker-compose logs: `docker-compose logs -f`
3. Test components individually
4. Consult the main KitiumAI documentation

---

**Last Updated**: 2024
**Template Version**: 1.0
**Maintainer**: KitiumAI Team
