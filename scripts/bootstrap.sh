#!/usr/bin/env bash
set -euo pipefail

mkdir -p /comfyui/models \
    /comfyui/input \
    /comfyui/output \
    /comfyui/user \
    /comfyui/custom_nodes \
    /comfyui/cache \
    /comfyui/temp \
    /comfyui/previews \
    /comfyui/datasets

/opt/ivbox/scripts/seed_defaults.sh
/opt/ivbox/scripts/link_nodes.sh

if [ "${IVBOX_BOOTSTRAP_ONLY:-0}" = "1" ]; then
    exit 0
fi
