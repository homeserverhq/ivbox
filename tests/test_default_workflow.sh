#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "${ROOT}/defaults/user/default/workflows/z-image-turbo.json" <<'PY'
import json
import sys

workflow = json.load(open(sys.argv[1]))
nodes = workflow["nodes"]

latent = next(node for node in nodes if node["type"] == "EmptySD3LatentImage")
vae = next(node for node in nodes if node["type"] == "VAELoader")

width, height = latent["widgets_values"][:2]
assert (width, height) == (512, 512), latent["widgets_values"]
assert vae["widgets_values"] == ["ae.safetensors"], vae["widgets_values"]

print("default workflow test: ok")
PY
