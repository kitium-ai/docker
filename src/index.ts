/**
 * @kitiumai/docker - Enterprise Docker management library
 * Provides Docker Compose operations, health checks, and error handling
 */

// Export types
export type {
  DockerService,
  DockerComposeConfig,
  DockerEnvironment,
  ComposeOptions,
  ContainerHealth,
  ServiceHealthCheck,
  BuildConfig,
  ImageMetadata,
  NetworkConfig,
  VolumeConfig,
} from './types';

// Export error utilities
export {
  extractErrorMetadata,
  createDockerComposeError,
  createDockerDaemonError,
  createContainerError,
  createHealthCheckError,
  createImageBuildError,
  createNetworkError,
  createVolumeError,
  createConfigurationError,
  type ErrorMetadata,
} from './utils/errors';

// Export managers
export { DockerComposeManager } from './docker-compose-manager';
