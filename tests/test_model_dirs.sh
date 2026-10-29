#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

mkdir -p "${TMP}/comfy" "${TMP}/models"

cat > "${TMP}/comfy/folder_paths.py" <<'EOF'
import os

models_dir = os.environ["IVBOX_MODELS_DIR"]

folder_names_and_paths = {
    "vae": ([os.path.join(models_dir, "vae")], set()),
    "diffusion_models": (
        [os.path.join(models_dir, "unet"), os.path.join(models_dir, "diffusion_models")],
        set(),
    ),
    "custom_nodes": ([os.path.join(os.path.dirname(models_dir), "custom_nodes")], set()),
}
EOF

run_ivbox_model_dirs() {
    IVBOX_BASE_DIR="${TMP}" \
    IVBOX_COMFY_DIR="${TMP}/comfy" \
    IVBOX_MODELS_DIR="${TMP}/models" \
    python3 "${ROOT}/scripts/model_dirs.py" "$@"
}

run_ivbox_model_dirs --dry-run >/dev/null
test ! -d "${TMP}/models/vae"

run_ivbox_model_dirs >/dev/null
test -d "${TMP}/models/vae"
test -d "${TMP}/models/unet"
test -d "${TMP}/models/diffusion_models"
test ! -d "${TMP}/custom_nodes"

run_ivbox_model_dirs >/dev/null
test -d "${TMP}/models/vae"

echo "model dirs test: ok"
