#!/bin/bash

# ============================================================================
# Database Backup Script for PostgreSQL
# Usage: ./scripts/backup-database.sh
# ============================================================================

set -e

# Configuration
BACKUP_DIR="${BACKUP_DIR:-.}/backups"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"
CONTAINER_NAME="${CONTAINER_NAME:-kitium-postgres}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/kitium_db_backup_$TIMESTAMP.sql.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "=========================================="
echo "Starting database backup"
echo "Backup directory: $BACKUP_DIR"
echo "Retention: $RETENTION_DAYS days"
echo "=========================================="

# Perform backup
echo "Backing up database from container: $CONTAINER_NAME"
docker exec "$CONTAINER_NAME" pg_dump -U "${POSTGRES_USER:-kitium}" "${POSTGRES_DB:-kitium_dev}" | gzip > "$BACKUP_FILE"

if [ -f "$BACKUP_FILE" ]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "✓ Backup completed successfully"
    echo "  File: $BACKUP_FILE"
    echo "  Size: $SIZE"
else
    echo "✗ Backup failed!"
    exit 1
fi

# Clean up old backups
echo "Cleaning up backups older than $RETENTION_DAYS days"
find "$BACKUP_DIR" -name "kitium_db_backup_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete

echo "=========================================="
echo "Backup completed at $(date)"
echo "=========================================="
