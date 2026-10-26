#!/usr/bin/env bash
set -euo pipefail

DEFAULTS_DIR="${IVBOX_DEFAULTS_DIR:-/opt/ivbox/defaults/user}"
USER_DIR="${IVBOX_USER_DIR:-/user}"

mkdir -p "${USER_DIR}"

if [ ! -d "${DEFAULTS_DIR}" ]; then
    echo "ivbox: no default user assets at ${DEFAULTS_DIR}" >&2
    exit 0
fi

cp -an "${DEFAULTS_DIR}/." "${USER_DIR}/"
