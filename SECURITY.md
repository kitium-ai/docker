# Security Guidelines

## Overview

This document outlines the security practices and guidelines for the @kitiumai/docker package.

## Docker Security Best Practices

### 1. Image Security

- **Use Alpine Linux** - Minimal base image reduces attack surface
- **Regular Updates** - Update base images regularly
- **Vulnerability Scanning**:
  ```bash
  docker scan kitium-api:latest
  trivy image kitium-api:latest
  ```

### 2. Container Runtime Security

- **Run as Non-root User** - All services run with uid: 1000
- **Resource Limits** - CPU and memory constraints prevent DoS
- **Read-only Root Filesystem** - Where applicable
- **No Privileged Containers** - Never use `--privileged` flag

### 3. Network Security

- **Custom Bridge Network** - Services isolated from external networks
- **No Port Exposure in Production** - Use reverse proxy for external access
- **Network Policies** - Restrict inter-service communication

### 4. Data Security

#### PostgreSQL

- **Strong Passwords** - Always change default credentials
- **Encrypted Connections** - Use SSL/TLS for connections
- **Access Control** - Limit database user permissions
- **Regular Backups** - Automated daily backups recommended

#### Redis

- **Password Protection** - Requires authentication
- **AOF Persistence** - Durability enabled
- **No Public Exposure** - Only accessible from internal network

### 5. Secrets Management

**DO NOT** commit secrets to version control:

```bash
# ❌ WRONG
git add .env  # Never commit actual .env

# ✅ CORRECT
git add .env.example
echo ".env" >> .gitignore
```

**Use environment variables or secrets management:**

```bash
# Docker Secrets (Swarm mode)
echo "my_secret" | docker secret create db_password -

# Environment variables
export POSTGRES_PASSWORD="secure_password"
docker-compose up
```

### 6. Image Build Security

- **Scan dependencies** for vulnerabilities
- **Use specific versions** - Avoid `latest` tags in production
- **Minimize layers** - Reduce attack surface
- **Clean up** - Remove unnecessary packages

### 7. Authentication & Authorization

- **API Authentication** - Implement JWT or OAuth2
- **Session Management** - Secure session cookies
- **CORS Configuration** - Restrict cross-origin requests
- **Rate Limiting** - Prevent brute force attacks

## Dependency Security

### Regular Updates

```bash
# Check for vulnerability updates
npm audit

# Update vulnerable packages
npm audit fix

# Docker image updates
docker pull postgres:15-alpine
docker pull redis:7-alpine
```

### Supply Chain Security

- **Use verified packages** from NPM registry
- **Pin versions** in package.json
- **Review dependencies** before updating
- **Monitor security advisories**:
  - https://www.npmjs.com/advisories
  - https://github.com/advisories

## Encryption

### Data in Transit

```yaml
# Enable HTTPS/TLS
- Use reverse proxy (Nginx, Traefik)
- Configure SSL certificates
- Redirect HTTP to HTTPS
```

### Data at Rest

```bash
# Database encryption
POSTGRES_INITDB_ARGS: "--auth=scram-sha-256"

# Volume encryption (Linux)
# Use dm-crypt or LUKS for encrypted volumes
```

## Access Control

### Database Users

```sql
-- Create limited privilege users
CREATE USER app_user WITH PASSWORD 'strong_password';
GRANT CONNECT ON DATABASE kitium_dev TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_user;
```

### Docker Registry

```bash
# Private registry authentication
docker login registry.example.com
docker push registry.example.com/kitium-api:v1.0.0
```

## Audit Logging

### Container Logs

```bash
# View audit logs
docker-compose logs --timestamps api

# Stream logs to syslog
# Configure in docker daemon.json
{
  "log-driver": "syslog",
  "log-opts": {
    "syslog-address": "udp://127.0.0.1:514"
  }
}
```

### Application Logging

```typescript
// Log security events
console.log({
  timestamp: new Date().toISOString(),
  event: 'user_login',
  user_id: userId,
  ip_address: ipAddress,
  status: 'success'
});
```

## Incident Response

### Detected Vulnerability

1. **Assess** - Determine severity and impact
2. **Isolate** - Stop affected containers
3. **Patch** - Update vulnerable component
4. **Test** - Verify fix in development
5. **Deploy** - Roll out fix to production
6. **Monitor** - Watch for exploitation attempts

### Security Breach

1. **Activate** - Incident response team
2. **Contain** - Isolate affected systems
3. **Investigate** - Determine scope and cause
4. **Notify** - Inform affected users
5. **Recover** - Restore from backups
6. **Review** - Post-incident analysis

## Security Checklist

### Development

- [ ] Non-root user in Dockerfile
- [ ] Resource limits configured
- [ ] Health checks implemented
- [ ] Secrets not in version control
- [ ] Dependencies scanned
- [ ] Logging configured
- [ ] Error handling implemented

### Pre-deployment

- [ ] All secrets configured externally
- [ ] Database passwords changed
- [ ] SSL/TLS certificates ready
- [ ] Backups tested
- [ ] Security scanning passed
- [ ] Load balancer configured
- [ ] Monitoring enabled

### Production

- [ ] Regular backups running
- [ ] Security updates automated
- [ ] Logs monitored for anomalies
- [ ] Access logs reviewed
- [ ] Incident response plan documented
- [ ] Security training completed
- [ ] Compliance verified

## Compliance

### GDPR

- **Data Privacy** - Implement data protection
- **Right to Erasure** - Ability to delete user data
- **Data Portability** - Export user data format
- **Privacy by Design** - Built-in privacy controls

### HIPAA (if applicable)

- **Encryption** - All data encrypted in transit and at rest
- **Access Controls** - Role-based access control
- **Audit Logging** - Comprehensive audit trails
- **Business Associate Agreements** - Third-party compliance

### SOC 2

- **Security** - Protect against unauthorized access
- **Availability** - System uptime monitoring
- **Processing Integrity** - Data accuracy
- **Confidentiality** - Data privacy
- **Privacy** - Personal data handling

## References

- [NIST Container Security Guide](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CVE Database](https://nvd.nist.gov/vuln/search)

## Report a Security Issue

Please report security vulnerabilities to **security@kitium.ai** instead of using the public issue tracker.

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if available)

---

**Last Updated**: 2024-01-21
**Version**: 1.0.0
