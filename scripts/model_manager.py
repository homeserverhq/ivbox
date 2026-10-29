#!/usr/bin/env python3
"""Small model download helper for the IVBox ComfyUI image."""

from __future__ import annotations

import argparse
import os
import shutil
import sys
from pathlib import Path

MODELS_DIR = Path(os.environ.get("IVBOX_MODELS_DIR", "/comfyui/models"))
STAGING_DIR = MODELS_DIR / ".staging"

MODEL_SETS: dict[str, dict] = {
    "z-image-turbo": {
        "repo": "Comfy-Org/Z-Image-Turbo",
        "description": "Z-Image Turbo default workflow (diffusion model, text encoder, VAE)",
        "revision": "6fc90a3b1b653e935a0d175e260736de25b84df5",
        "patterns": [
            "split_files/diffusion_models/z_image_turbo_bf16.safetensors",
            "split_files/text_encoders/qwen_3_4b.safetensors",
            "split_files/vae/ae.safetensors",
        ],
    },
    "qwen-image": {
        "repo": "Comfy-Org/Qwen-Image_ComfyUI",
        "description": "Qwen Image 2512 ComfyUI repack",
    },
    "qwen-image-edit": {
        "repo": "Comfy-Org/Qwen-Image-Edit_ComfyUI",
        "description": "Qwen Image Edit 2511 ComfyUI repack",
    },
    "wan-t2v": {
        "repo": "Comfy-Org/Wan_2.2_ComfyUI_Repackaged",
        "description": "Wan 2.2 text-to-video repack",
    },
    "wan-i2v": {
        "repo": "Comfy-Org/Wan_2.2_ComfyUI_Repackaged",
        "description": "Wan 2.2 image-to-video repack",
    },
}

CATEGORIES = (
    "diffusion_models",
    "unet",
    "text_encoders",
    "clip",
    "vae",
    "loras",
    "clip_vision",
    "latent_upscale_models",
    "checkpoints",
)

MODEL_SUFFIXES = {".safetensors", ".gguf", ".ckpt", ".pt", ".pth", ".bin"}

DEFAULT_ALLOW_PATTERNS = [
    "*.safetensors",
    "*.gguf",
    "*.ckpt",
    "*.pt",
    "*.pth",
    "*.bin",
    "*.json",
]


def print_sets() -> None:
    print("Available model sets:\n")
    for name, info in MODEL_SETS.items():
        print(f"  {name:18} {info['description']}")
        print(f"  {'':18} repo: {info['repo']}\n")


def category_for(relative: Path) -> tuple[str, Path]:
    parts = relative.parts
    for category in CATEGORIES:
        if category in parts:
            index = parts.index(category)
            rest = Path(*parts[index + 1 :])
            return category, rest if rest.name else Path(relative.name)
    return "checkpoints", Path(relative.name)


def move_into_place(staging: Path, dry_run: bool) -> int:
    moved = 0
    for path in sorted(staging.rglob("*")):
        if not path.is_file():
            continue
        if path.suffix.lower() not in MODEL_SUFFIXES:
            continue

        category, rest = category_for(path.relative_to(staging))
        destination = MODELS_DIR / category / rest
        print(f"{'would place' if dry_run else 'placing'}: {path} -> {destination}")
        if dry_run:
            moved += 1
            continue

        destination.parent.mkdir(parents=True, exist_ok=True)
        if destination.exists():
            path.unlink()
            continue
        shutil.move(str(path), str(destination))
        moved += 1
    return moved


def download(name: str, revision: str | None, dry_run: bool) -> int:
    info = MODEL_SETS[name]
    revision = revision or info.get("revision")
    patterns = info.get("patterns") or DEFAULT_ALLOW_PATTERNS

    target = STAGING_DIR / name
    if target.exists() and not dry_run:
        shutil.rmtree(target)

    print(f"Downloading {name} from {info['repo']} ...")
    print(f"  revision: {revision or 'main'}")
    print(f"  patterns: {', '.join(patterns)}")
    if dry_run:
        print(f"would download into {target}")
        return 0

    try:
        from huggingface_hub import snapshot_download
    except ImportError:
        print("huggingface_hub is not installed", file=sys.stderr)
        return 2

    target.mkdir(parents=True, exist_ok=True)

    try:
        snapshot_download(
            repo_id=info["repo"],
            revision=revision,
            local_dir=target,
            allow_patterns=patterns,
        )
    except Exception as exc:
        print(f"download failed: {exc}", file=sys.stderr)
        return 1

    moved = move_into_place(target, dry_run=False)
    shutil.rmtree(target, ignore_errors=True)
    print(f"Placed {moved} model file(s) under {MODELS_DIR}")
    return 0


def verify() -> int:
    missing = 0
    for category in CATEGORIES:
        directory = MODELS_DIR / category
        files = [
            path
            for path in directory.rglob("*")
            if path.is_file() and path.suffix.lower() in MODEL_SUFFIXES
        ] if directory.is_dir() else []
        if files:
            total = sum(path.stat().st_size for path in files)
            print(f"{category:24} {len(files):4d} file(s)  {total / 1024**3:7.2f} GiB")
        else:
            print(f"{category:24}    0 file(s)")
            missing += 1
    return 0 if missing < len(CATEGORIES) else 1


def interactive() -> int:
    print_sets()
    choice = input("Model set to download (blank to quit): ").strip()
    if not choice:
        return 0
    if choice not in MODEL_SETS:
        print(f"unknown model set: {choice}", file=sys.stderr)
        return 2
    return download(choice, None, False)


def main() -> int:
    global MODELS_DIR, STAGING_DIR

    parser = argparse.ArgumentParser(description="IVBox ComfyUI model manager")
    parser.add_argument("--models-dir", type=Path, default=MODELS_DIR)
    parser.add_argument("--revision", default=None)
    parser.add_argument("--dry-run", action="store_true")
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("list", help="list available model sets")
    sub.add_parser("verify", help="show downloaded model files")

    download_parser = sub.add_parser("download", help="download model sets")
    download_parser.add_argument("sets", nargs="+", choices=sorted(MODEL_SETS))
    download_parser.add_argument("--revision", default=None)
    download_parser.add_argument("--dry-run", action="store_true")

    args = parser.parse_args()

    MODELS_DIR = args.models_dir
    STAGING_DIR = MODELS_DIR / ".staging"
    MODELS_DIR.mkdir(parents=True, exist_ok=True)

    if args.command == "list":
        print_sets()
        return 0
    if args.command == "verify":
        return verify()
    if args.command == "download":
        for name in args.sets:
            status = download(name, args.revision, args.dry_run)
            if status != 0:
                return status
        return 0

    return interactive()


if __name__ == "__main__":
    raise SystemExit(main())
