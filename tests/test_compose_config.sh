#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

test -f stack.env || cp stack.env.example stack.env
docker compose config >/dev/null
echo "compose config test: ok"
