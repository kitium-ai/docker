#!/usr/bin/env bash
set -euo pipefail

SERVICE=${1:-api}
COMMAND=${MIGRATION_COMMAND:-"pnpm --filter=@kitium-ai/${SERVICE} prisma migrate deploy"}

if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose is required" >&2
  exit 1
fi

echo "[migrations] Running migration command in ${SERVICE}"
docker compose run --rm "$SERVICE" sh -c "$COMMAND"
