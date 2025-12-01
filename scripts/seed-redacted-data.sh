#!/usr/bin/env bash
set -euo pipefail

SEED_FILE=${1:-./scripts/seed-data.sql}
CONTAINER=${POSTGRES_CONTAINER:-kitium-postgres}

if [ ! -f "$SEED_FILE" ]; then
  echo "Seed file not found: $SEED_FILE" >&2
  exit 1
fi

echo "[seed] Loading redacted seed data into $CONTAINER"
docker exec -i "$CONTAINER" psql -U ${POSTGRES_USER:-kitium} -d ${POSTGRES_DB:-kitium_dev} < "$SEED_FILE"
echo "[seed] Done"
