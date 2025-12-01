#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR=${1:-backups/wal}
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
mkdir -p "$BACKUP_DIR"

CONTAINER=${POSTGRES_CONTAINER:-kitium-postgres}
ARCHIVE_FILE="$BACKUP_DIR/wal_${TIMESTAMP}.tar.gz"

echo "[wal-backup] Archiving WAL files from $CONTAINER to $ARCHIVE_FILE"
docker exec "$CONTAINER" pg_basebackup -D /tmp/wal-archive -Ft -z -Xs -P

docker cp "$CONTAINER":/tmp/wal-archive "$ARCHIVE_FILE"
docker exec "$CONTAINER" rm -rf /tmp/wal-archive

echo "[wal-backup] Done"
