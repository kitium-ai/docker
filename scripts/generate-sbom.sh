#!/usr/bin/env bash
set -euo pipefail

IMAGE=${1:-kitium/api:local}
OUTPUT=${2:-./sbom-${IMAGE//\//_}.spdx.json}

if ! command -v syft >/dev/null 2>&1; then
  echo "syft is required (https://github.com/anchore/syft)" >&2
  exit 1
fi

echo "[sbom] Generating SBOM for $IMAGE -> $OUTPUT"
syft "$IMAGE" -o spdx-json > "$OUTPUT"
