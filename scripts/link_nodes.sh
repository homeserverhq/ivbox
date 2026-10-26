#!/usr/bin/env bash
set -euo pipefail

BAKED_DIR="${IVBOX_BAKED_NODES_DIR:-/opt/ivbox/custom_nodes}"
USER_NODES_DIR="${IVBOX_CUSTOM_NODES_DIR:-/custom_nodes}"

mkdir -p "${USER_NODES_DIR}"

if [ ! -d "${BAKED_DIR}" ]; then
    echo "ivbox: no baked custom nodes at ${BAKED_DIR}" >&2
    exit 0
fi

for src in "${BAKED_DIR}"/*; do
    [ -d "${src}" ] || continue
    name="$(basename "${src}")"
    dest="${USER_NODES_DIR}/${name}"

    if [ -L "${dest}" ]; then
        ln -sfn "${src}" "${dest}"
    elif [ ! -e "${dest}" ]; then
        ln -s "${src}" "${dest}"
    else
        echo "ivbox: keeping user-managed node ${name}" >&2
    fi
done

while IFS= read -r link; do
    [ -e "${link}" ] || rm -f "${link}"
done < <(find "${USER_NODES_DIR}" -maxdepth 1 -type l -lname "${BAKED_DIR}/*" 2>/dev/null || true)
