#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

mkdir -p "${TMP}/defaults/user/default/workflows"
printf '{"test": true}\n' > "${TMP}/defaults/user/default/workflows/test.json"
mkdir -p "${TMP}/baked/TestNode"
mkdir -p "${TMP}/custom_nodes" "${TMP}/user"

IVBOX_DEFAULTS_DIR="${TMP}/defaults/user" \
IVBOX_USER_DIR="${TMP}/user" \
"${ROOT}/scripts/seed_defaults.sh"

IVBOX_BAKED_NODES_DIR="${TMP}/baked" \
IVBOX_CUSTOM_NODES_DIR="${TMP}/custom_nodes" \
"${ROOT}/scripts/link_nodes.sh"

test -f "${TMP}/user/default/workflows/test.json"
test -L "${TMP}/custom_nodes/TestNode"

echo "bootstrap test: ok"
