#!/usr/bin/env python3
"""Create the model directories registered by the installed ComfyUI."""

from __future__ import annotations

import argparse
import os
import sys

BASE_DIR = os.environ.get("IVBOX_BASE_DIR", "/comfyui")
COMFY_DIR = os.environ.get("IVBOX_COMFY_DIR", "/opt/ComfyUI")


def registered_model_paths() -> tuple[str, list[str]]:
    sys.argv = ["main.py", "--base-directory", BASE_DIR]
    sys.path.insert(0, COMFY_DIR)
    try:
        import comfy.options

        comfy.options.enable_args_parsing()
    except Exception:
        pass
    import folder_paths

    root = os.path.abspath(folder_paths.models_dir)
    paths: list[str] = []
    for entries, _extensions in folder_paths.folder_names_and_paths.values():
        for entry in entries:
            path = os.path.abspath(entry)
            if path != root and not path.startswith(root + os.sep):
                continue
            if path not in paths:
                paths.append(path)
    return root, sorted(paths)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="report what would be created without touching the filesystem",
    )
    args = parser.parse_args()

    try:
        root, paths = registered_model_paths()
    except Exception as exc:
        print(
            f"ivbox: could not resolve ComfyUI model directories: {exc}",
            file=sys.stderr,
        )
        return 0

    created = 0
    for path in paths:
        if os.path.isdir(path):
            if args.dry_run:
                print(f"exists: {path}")
            continue
        print(f"{'would create' if args.dry_run else 'created'}: {path}")
        if not args.dry_run:
            os.makedirs(path, exist_ok=True)
        created += 1

    if args.dry_run:
        print(f"\n{len(paths)} model directories registered under {root}")
    else:
        print(f"ivbox: model directories ready under {root} ({created} created)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
