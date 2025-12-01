#!/usr/bin/env bash
set -euo pipefail

ARCHIVE_PATH=${1:?"Usage: restore-wal.sh <archive.tar.gz>"}
CONTAINER=${POSTGRES_CONTAINER:-kitium-postgres}

if [ ! -f "$ARCHIVE_PATH" ]; then
  echo "Archive not found: $ARCHIVE_PATH" >&2
  exit 1
fi

echo "[wal-restore] Restoring WAL archive $ARCHIVE_PATH into $CONTAINER"
docker cp "$ARCHIVE_PATH" "$CONTAINER":/tmp/wal-archive.tar.gz
docker exec "$CONTAINER" bash -c "cd /var/lib/postgresql/data && tar -xzf /tmp/wal-archive.tar.gz && rm /tmp/wal-archive.tar.gz"
echo "[wal-restore] Completed"
