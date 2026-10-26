#!/usr/bin/env python3
"""Print the model files visible under the IVBox model directory."""

from __future__ import annotations

import os
from pathlib import Path

MODELS_DIR = Path(os.environ.get("IVBOX_MODELS_DIR", "/comfyui/models"))
SUFFIXES = {".safetensors", ".gguf", ".ckpt", ".pt", ".pth", ".bin"}


def main() -> int:
    if not MODELS_DIR.is_dir():
        print(f"missing model directory: {MODELS_DIR}")
        return 1

    found = 0
    for path in sorted(MODELS_DIR.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in SUFFIXES:
            continue
        relative = path.relative_to(MODELS_DIR)
        size = path.stat().st_size / 1024**3
        print(f"{size:8.2f} GiB  {relative}")
        found += 1

    print(f"\n{found} model file(s) under {MODELS_DIR}")
    return 0 if found else 1


if __name__ == "__main__":
    raise SystemExit(main())
