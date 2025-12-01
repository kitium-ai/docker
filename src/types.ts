/**
 * Docker configuration and operation types
 */

/**
 * Docker Compose service definition
 */
export interface DockerService {
  name: string;
  image?: string;
  container_name?: string;
  ports?: string[];
  environment?: Record<string, string>;
  volumes?: string[];
  depends_on?: string[];
  networks?: string[];
  healthcheck?: {
    test: string[] | string;
    interval: string;
    timeout: string;
    retries: number;
    start_period?: string;
  };
}

/**
 * Docker Compose configuration
 */
export interface DockerComposeConfig {
  version: string;
  services: Record<string, DockerService>;
  volumes?: Record<string, Record<string, unknown>>;
  networks?: Record<string, Record<string, unknown>>;
  environment?: Record<string, string>;
}

/**
 * Docker environment configuration
 */
export interface DockerEnvironment {
  env: 'development' | 'staging' | 'production';
  platform?: string;
  registry?: string;
  registryUsername?: string;
  registryPassword?: string;
}

/**
 * Docker Compose operation options
 */
export interface ComposeOptions {
  files: string[];
  projectName?: string;
  workdir?: string;
  env?: Record<string, string>;
}

/**
 * Container health status
 */
export interface ContainerHealth {
  status: 'healthy' | 'unhealthy' | 'starting' | 'unknown';
  message?: string;
  timestamp: Date;
  lastCheck: Date;
}

/**
 * Service health check result
 */
export interface ServiceHealthCheck {
  serviceName: string;
  endpoint: string;
  healthy: boolean;
  statusCode?: number;
  responseTime: number;
  timestamp: Date;
  error?: string;
}

/**
 * Docker build configuration
 */
export interface BuildConfig {
  dockerfilePath: string;
  imageName: string;
  tag?: string;
  buildArgs?: Record<string, string>;
  context?: string;
  buildOptions?: Record<string, unknown>;
}

/**
 * Image metadata
 */
export interface ImageMetadata {
  id: string;
  name: string;
  tag?: string;
  size: number;
  created: Date;
  digest?: string;
}

/**
 * Network configuration
 */
export interface NetworkConfig {
  name: string;
  driver: 'bridge' | 'host' | 'overlay' | 'macvlan' | 'none';
  subnet?: string;
  gateway?: string;
  labels?: Record<string, string>;
}

/**
 * Volume configuration
 */
export interface VolumeConfig {
  name: string;
  driver?: string;
  mountpoint?: string;
  labels?: Record<string, string>;
}
