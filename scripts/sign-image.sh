#!/usr/bin/env bash
set -euo pipefail

IMAGE=${1:?"Usage: sign-image.sh <image>"}
COSIGN_KEY=${COSIGN_KEY:-cosign.key}

if ! command -v cosign >/dev/null 2>&1; then
  echo "cosign is required (https://github.com/sigstore/cosign)" >&2
  exit 1
fi

echo "[cosign] Signing $IMAGE"
COSIGN_EXPERIMENTAL=1 cosign sign --key "$COSIGN_KEY" "$IMAGE"
