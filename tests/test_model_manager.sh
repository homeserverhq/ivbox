#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

python3 "${ROOT}/scripts/model_manager.py" list | grep -q 'z-image-turbo'

out="$(python3 "${ROOT}/scripts/model_manager.py" --models-dir "${TMP}" download z-image-turbo --dry-run)"
grep -q 'Comfy-Org/Z-Image-Turbo' <<<"${out}"
grep -q 'z_image_turbo_bf16.safetensors' <<<"${out}"
grep -q 'qwen_3_4b.safetensors' <<<"${out}"
grep -q '6fc90a3b1b653e935a0d175e260736de25b84df5' <<<"${out}"

echo "model manager test: ok"
