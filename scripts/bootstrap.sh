#!/usr/bin/env bash
set -euo pipefail

mkdir -p /models /input /output /user /custom_nodes /cache /temp

if [ -e /opt/ComfyUI/custom_nodes ] && [ ! -L /opt/ComfyUI/custom_nodes ]; then
    rm -rf /opt/ComfyUI/custom_nodes
fi
ln -sfn /custom_nodes /opt/ComfyUI/custom_nodes

/opt/ivbox/scripts/seed_defaults.sh
/opt/ivbox/scripts/link_nodes.sh

if [ "${IVBOX_BOOTSTRAP_ONLY:-0}" = "1" ]; then
    exit 0
fi
