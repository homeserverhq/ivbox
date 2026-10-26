#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source /opt/ivbox/scripts/env.sh

/opt/ivbox/scripts/bootstrap.sh

if [ "${IVBOX_BOOTSTRAP_ONLY:-0}" = "1" ]; then
    exit 0
fi

if [ "${IVBOX_SKIP_GPU_CHECK:-0}" != "1" ]; then
    if ! python /opt/ivbox/scripts/gpu_check.py; then
        cat >&2 <<'EOF'

ivbox: GPU preflight failed.

This usually means the PyTorch/ROCm build is incompatible with the host
kernel, firmware, or GPU driver. The container will not start ComfyUI.

Current image stack:
  torch 2.12.0a0+rocm7.12.0a20260310

If this is a segfault, do not change ComfyUI flags; the torch/ROCm stack
must be matched to the host.
EOF
        exit 1
    fi
fi

DEFAULT_FLAGS=(--bf16-vae --disable-mmap)

if [ -n "${COMFYUI_FLAGS:-}" ]; then
    read -r -a COMFY_FLAGS <<< "${COMFYUI_FLAGS}"
else
    COMFY_FLAGS=("${DEFAULT_FLAGS[@]}")
fi

EXTRA_ARGS=()
if [ -n "${COMFYUI_ARGS:-}" ]; then
    read -r -a EXTRA_ARGS <<< "${COMFYUI_ARGS}"
fi

cd /opt/ComfyUI

exec python main.py \
    --listen 0.0.0.0 \
    --port "${COMFYUI_PORT:-8188}" \
    --models-directory /models \
    --input-directory /input \
    --output-directory /output \
    --user-directory /user \
    --temp-directory /temp \
    "${COMFY_FLAGS[@]}" \
    "${EXTRA_ARGS[@]}"
