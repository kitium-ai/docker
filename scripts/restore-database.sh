#!/bin/bash

# ============================================================================
# Database Restoration Script for PostgreSQL
# Usage: ./scripts/restore-database.sh <backup_file>
# Example: ./scripts/restore-database.sh backups/kitium_db_backup_20231121_120000.sql.gz
# ============================================================================

set -e

CONTAINER_NAME="${CONTAINER_NAME:-kitium-postgres}"
BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
    echo "Error: Backup file path is required"
    echo "Usage: $0 <backup_file>"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "=========================================="
echo "Starting database restoration"
echo "Backup file: $BACKUP_FILE"
echo "Container: $CONTAINER_NAME"
echo "=========================================="

# Confirm restoration
read -p "Are you sure you want to restore? This will overwrite the current database. (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Restoration cancelled"
    exit 0
fi

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: Container $CONTAINER_NAME is not running"
    exit 1
fi

# Restore database
echo "Restoring database..."
zcat "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "${POSTGRES_USER:-kitium}" "${POSTGRES_DB:-kitium_dev}"

echo "✓ Database restored successfully"
echo "=========================================="
echo "Restoration completed at $(date)"
echo "=========================================="
