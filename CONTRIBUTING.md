# Contributing to @kitiumai/docker

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Code of Conduct

This project adheres to the Contributor Covenant Code of Conduct. By participating, you are expected to uphold this code.

## How to Contribute

### 1. Report Bugs

**Before reporting**, check if the issue already exists.

Include in bug reports:
- Docker version: `docker --version`
- Docker Compose version: `docker-compose --version`
- OS and version
- Steps to reproduce
- Expected vs actual behavior
- Logs and error messages

### 2. Suggest Enhancements

Suggest enhancements by opening an issue with:
- Clear description of the feature
- Motivation and use case
- Possible implementation approach
- Alternative solutions considered

### 3. Submit Code

#### Setup Development Environment

```bash
git clone https://github.com/kitium-ai/docker.git
cd docker
cp .env.example .env
npm install
npm run dev:build
npm run dev
```

#### Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

#### Make Changes

Follow these guidelines:

1. **Code Style**
   - Follow existing code style
   - Use meaningful variable names
   - Add comments for complex logic
   - Keep functions small and focused

2. **Dockerfiles**
   - Use multi-stage builds
   - Minimize layer count
   - Add health checks
   - Use Alpine when possible
   - Don't run as root

3. **Docker Compose**
   - Document all environment variables
   - Include resource limits
   - Define proper health checks
   - Use meaningful container names
   - Keep overrides separate

4. **Scripts**
   - Make scripts executable: `chmod +x script.sh`
   - Add shebang: `#!/bin/bash`
   - Handle errors: `set -e`
   - Add usage documentation

5. **Documentation**
   - Update README.md if needed
   - Add comments to complex sections
   - Include examples
   - Document breaking changes

#### Commit Messages

Follow conventional commits:

```
type(scope): subject

body

footer
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`

**Examples**:
```
feat(api): add request logging middleware

docs(readme): update installation instructions

fix(docker-compose): correct health check interval

chore(deps): update node base image to 18.18.0
```

#### Test Your Changes

```bash
# Validate Docker Compose
npm run validate

# Build services
npm run dev:build

# Start services
npm run dev

# Check health
npm run healthcheck

# Run tests
npm run test

# Check logs for errors
npm run logs

# Cleanup
npm run dev:down
```

#### Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Create a pull request with:
- Clear title and description
- Reference related issues: `Closes #123`
- Screenshots/logs if applicable
- Testing performed

## Pull Request Process

1. **Review** - At least one maintainer reviews
2. **Tests** - All tests must pass
3. **Documentation** - README updated if needed
4. **Approval** - Maintainer approval required
5. **Merge** - Use "Squash and merge" for cleaner history

## Style Guide

### Dockerfile Best Practices

```dockerfile
# ✅ GOOD
FROM node:18-alpine AS base
RUN apk update && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/*
USER appuser

# ❌ BAD
FROM node:latest
RUN apk update && apk add curl && apk cache clean
USER root
```

### Docker Compose YAML

```yaml
# ✅ GOOD
services:
  api:
    build:
      context: ./services/api
      target: production
    container_name: kitium-api
    environment:
      NODE_ENV: ${NODE_ENV:-production}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

# ❌ BAD
services:
  api:
    build: ./services/api
    environment:
      NODE_ENV: production
```

### Documentation

- Use clear, concise language
- Add code examples where helpful
- Keep documentation up-to-date
- Use proper markdown formatting

## Project Structure

```
docker/
├── services/          # Service-specific code and configs
├── scripts/           # Utility and automation scripts
├── volumes/           # Data persistence directories
├── docker-compose*.yml  # Compose configurations
├── README.md          # Main documentation
├── SECURITY.md        # Security guidelines
└── CONTRIBUTING.md    # This file
```

## Release Process

1. Update version in `package.json`
2. Update `CHANGELOG.md`
3. Create git tag: `git tag v1.0.0`
4. Push tag: `git push origin v1.0.0`
5. Create GitHub release with notes

## Questions?

- Open an issue with your question
- Check existing documentation
- Review closed issues for similar topics
- Contact maintainers: dev@kitium.ai

## Recognition

Contributors will be:
- Listed in CHANGELOG.md
- Recognized in GitHub contributors
- Mentioned in release notes

Thank you for helping improve @kitiumai/docker! 🚀
