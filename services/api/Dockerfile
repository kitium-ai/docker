# ============================================================================
# Multi-stage Docker build for API service
# Stage 1: Base - common dependencies
# ============================================================================
FROM node:18-alpine AS base
LABEL maintainer="Kitium AI <dev@kitium.ai>"
LABEL description="Enterprise-grade API service for Kitium AI"
LABEL version="1.0.0"

# Set working directory
WORKDIR /app

# Install security updates and required system packages
RUN apk update && \
    apk add --no-cache \
    dumb-init \
    curl \
    ca-certificates && \
    rm -rf /var/cache/apk/*

# Create non-root user for security
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# ============================================================================
# Stage 2: Dependencies - install and cache dependencies
# ============================================================================
FROM base AS dependencies

# Copy package files
COPY package*.json ./

# Install production dependencies with security audit
RUN npm ci --only=production && \
    npm audit fix --production || true && \
    npm cache clean --force

# ============================================================================
# Stage 3: Development - includes dev dependencies
# ============================================================================
FROM dependencies AS development

# Install development dependencies
RUN npm ci && \
    npm cache clean --force

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["/usr/sbin/dumb-init", "--"]

# Run in development mode
CMD ["npm", "run", "dev"]

# ============================================================================
# Stage 4: Builder - build application
# ============================================================================
FROM dependencies AS builder

# Copy application code
COPY . .

# Build application (if needed)
RUN npm run build --if-present

# ============================================================================
# Stage 5: Production - minimal production image
# ============================================================================
FROM base AS production

# Set environment to production
ENV NODE_ENV=production

# Copy only production dependencies from dependencies stage
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=dependencies /app/package*.json ./

# Copy built application from builder stage
COPY --from=builder /app ./

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["/usr/sbin/dumb-init", "--"]

# Start application
CMD ["node", "dist/index.js"]
