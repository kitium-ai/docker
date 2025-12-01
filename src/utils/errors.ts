/**
 * Centralized error handling with KitiumError factory functions
 * Provides structured error types for Docker operations
 */

import { KitiumError, type ErrorSeverity } from '@kitiumai/error';

/**
 * Error metadata for structured logging and error tracking
 */
export interface ErrorMetadata {
  code: string;
  kind: string;
  severity: ErrorSeverity;
  statusCode: number;
  retryable: boolean;
  help?: string;
  docs?: string;
}

/**
 * Extract error metadata from KitiumError for logging
 */
export function extractErrorMetadata(error: unknown): ErrorMetadata {
  if (error instanceof KitiumError) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const kitiumError = error as any;
    return {
      code: kitiumError.code,
      kind: kitiumError.kind,
      severity: kitiumError.severity,
      statusCode: kitiumError.statusCode,
      retryable: kitiumError.retryable,
      help: kitiumError.help,
      docs: kitiumError.docs,
    };
  }

  return {
    code: 'docker/unknown',
    kind: 'unknown',
    severity: 'error',
    statusCode: 500,
    retryable: false,
  };
}

/**
 * Docker Compose configuration error
 */
export function createDockerComposeError(
  operation: string,
  reason: string,
  context?: Record<string, unknown>
): KitiumError {
  return new KitiumError({
    code: 'docker/compose',
    message: `Docker Compose operation failed: ${operation} - ${reason}`,
    statusCode: 400,
    severity: 'error',
    kind: 'docker_compose_error',
    retryable: false,
    help: 'Verify Docker Compose configuration and environment setup',
    docs: 'https://docs.kitium.ai/errors/docker/compose',
    context: { operation, reason, ...context },
  });
}

/**
 * Docker daemon connection error
 */
export function createDockerDaemonError(
  operation: string,
  reason: string,
  context?: Record<string, unknown>
): KitiumError {
  return new KitiumError({
    code: 'docker/daemon',
    message: `Failed to connect to Docker daemon: ${operation} - ${reason}`,
    statusCode: 503,
    severity: 'error',
    kind: 'docker_daemon_error',
    retryable: true,
    help: 'Ensure Docker daemon is running and accessible',
    docs: 'https://docs.kitium.ai/errors/docker/daemon',
    context: { operation, reason, ...context },
  });
}

/**
 * Container operation error
 */
export function createContainerError(
  operation: string,
  container: string,
  reason: string,
  context?: Record<string, unknown>
): KitiumError {
  return new KitiumError({
    code: 'docker/container',
    message: `Container operation failed: ${operation} (${container}) - ${reason}`,
    statusCode: 422,
    severity: 'warning',
    kind: 'container_error',
    retryable: true,
    help: 'Check container logs and ensure required services are running',
    docs: 'https://docs.kitium.ai/errors/docker/container',
    context: { operation, container, reason, ...context },
  });
}

/**
 * Service health check error
 */
export function createHealthCheckError(
  service: string,
  endpoint: string,
  reason: string,
  context?: Record<string, unknown>
): KitiumError {
  return new KitiumError({
    code: 'docker/health-check',
    message: `Service health check failed: ${service} (${endpoint}) - ${reason}`,
    statusCode: 503,
    severity: 'warning',
    kind: 'health_check_error',
    retryable: true,
    help: 'Verify service is running and health endpoint is accessible',
    docs: 'https://docs.kitium.ai/errors/docker/health-check',
    context: { service, endpoint, reason, ...context },
  });
}

/**
 * Image build error
 */
export function createImageBuildError(
  image: string,
  reason: string,
  context?: Record<string, unknown>
): KitiumError {
  return new KitiumError({
    code: 'docker/image-build',
    message: `Failed to build Docker image: ${image} - ${reason}`,
    statusCode: 422,
    severity: 'error',
    kind: 'image_build_error',
    retryable: true,
    help: 'Check Dockerfile syntax and build context',
    docs: 'https://docs.kitium.ai/errors/docker/image-build',
    context: { image, reason, ...context },
  });
}

/**
 * Network operation error
 */
export function createNetworkError(
  operation: string,
  network: string,
  reason: string,
  context?: Record<string, unknown>
): KitiumError {
  return new KitiumError({
    code: 'docker/network',
    message: `Docker network operation failed: ${operation} (${network}) - ${reason}`,
    statusCode: 503,
    severity: 'warning',
    kind: 'network_error',
    retryable: true,
    help: 'Check Docker network configuration and connectivity',
    docs: 'https://docs.kitium.ai/errors/docker/network',
    context: { operation, network, reason, ...context },
  });
}

/**
 * Volume operation error
 */
export function createVolumeError(
  operation: string,
  volume: string,
  reason: string,
  context?: Record<string, unknown>
): KitiumError {
  return new KitiumError({
    code: 'docker/volume',
    message: `Docker volume operation failed: ${operation} (${volume}) - ${reason}`,
    statusCode: 422,
    severity: 'warning',
    kind: 'volume_error',
    retryable: true,
    help: 'Check Docker volume configuration and disk space',
    docs: 'https://docs.kitium.ai/errors/docker/volume',
    context: { operation, volume, reason, ...context },
  });
}

/**
 * Configuration validation error
 */
export function createConfigurationError(
  field: string,
  reason: string,
  context?: Record<string, unknown>
): KitiumError {
  return new KitiumError({
    code: 'docker/configuration',
    message: `Docker configuration error in field '${field}': ${reason}`,
    statusCode: 400,
    severity: 'error',
    kind: 'configuration_error',
    retryable: false,
    help: 'Check Docker configuration and environment variables',
    docs: 'https://docs.kitium.ai/errors/docker/configuration',
    context: { field, reason, ...context },
  });
}

/**
 * Backward compatibility error classes
 * These are kept for gradual migration to KitiumError
 */

export class DockerComposeError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'DockerComposeError';
  }
}

export class DockerDaemonError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'DockerDaemonError';
  }
}

export class ContainerError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ContainerError';
  }
}

export class HealthCheckError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'HealthCheckError';
  }
}

export class ImageBuildError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ImageBuildError';
  }
}

export class NetworkError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'NetworkError';
  }
}

export class VolumeError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'VolumeError';
  }
}
