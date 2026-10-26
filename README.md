# IVBox

**ComfyUI for AMD Strix Halo, without the setup.**

IVBox is a ready-to-run ComfyUI container built for AMD Strix Halo (`gfx1151`).
It comes with the node packs already installed, a model downloader, and a GPU
health check. Drop your models in, open the UI, and start creating.

No model weights are included.

## What you get

- ComfyUI, already installed and configured
- 20 ComfyUI node packs baked in
- `model_manager` for downloading common model sets
- `ivbox-doctor` for GPU, storage, and ComfyUI checks
- Persistent models, workflows, outputs, and settings
- A known-good ROCm 7.12 stack pinned for Strix Halo

## Requirements

- AMD Strix Halo system with a working `amdgpu` driver (`gfx1151`)
- Docker and Docker Compose
- Access to `/dev/kfd` and `/dev/dri`
- Enough disk space for your models

The compose file adds the container to the `video` and `render` groups
automatically.

## Quick start

```bash
cp stack.env.example stack.env
docker compose build
docker compose up -d
```

The first build downloads a lot and can take a while. Later builds reuse the
cache.

Open:

```text
http://localhost:9642/
```

To stop:

```bash
docker compose down
```

## Where your files live

| Host | Container | What it holds |
|---|---|---|
| `./comfyui` | `/comfyui` | Inputs, outputs, workflows, settings, custom nodes, scratch data |
| `./comfyui-models` | `/comfyui/models` | Model files |
| `./hf-cache` | `/root/.cache/huggingface` | Hugging Face download cache |

Missing directories and subdirectories are created automatically.

## Models

Put models in `./comfyui-models`. They appear in ComfyUI at
`/comfyui/models`.

The built-in helper can download a few common model sets:

```bash
docker compose exec -it ivbox-app model_manager list
docker compose exec -it ivbox-app model_manager download qwen-image qwen-image-edit
docker compose exec -it ivbox-app model_manager download wan-t2v wan-i2v
docker compose exec ivbox-app model_manager verify
```

Downloads use `./hf-cache` for the Hugging Face cache and then place the model
files into the correct model folders.

## Workflows

Workflows live here:

```text
./comfyui/user/default/workflows/
```

The folder is created on first start. Existing workflows are never overwritten.

## Included node packs

<details>
<summary>Show the full list</summary>

- ComfyUI-Manager
- ComfyUI_essentials
- ComfyUI-AMDGPUMonitor
- ComfyMath
- ComfyUI-GGUF-H3
- ComfyUI-Impact-Pack
- ComfyUI-KJNodes
- ComfyUI-MelBandRoFormer
- ComfyUI-VideoHelperSuite
- ComfyUI-VoxCPMTTS
- ComfyUI_Comfyroll_CustomNodes
- comfy_mtb
- ComfyUI-Advanced-ControlNet
- ComfyUI-Custom-Scripts
- ComfyUI-Easy-Use
- comfyui_controlnet_aux
- ComfyUI_Patches_ll
- calcuis/gguf
- rgthree-comfy
- ComfyUI-MiniMax-H3-Turbo

</details>

The image keeps its node packs in `/opt/ivbox/custom_nodes` and links them into
`./comfyui/custom_nodes` at startup. If you add your own node pack with the same
name, your local copy takes precedence.

ComfyUI-Manager is set to offline mode so it does not update node packs or
surprise you at startup. You can change that in:

```text
./comfyui/user/__manager/config.ini
```

## Settings

Copy `stack.env.example` to `stack.env` and adjust as needed.

| Setting | Default | What it does |
|---|---|---|
| `COMFYUI_PORT` | `8188` | ComfyUI port inside the container |
| `COMFYUI_FLAGS` | `--bf16-vae --disable-mmap` | Main ComfyUI runtime flags |
| `COMFYUI_ARGS` | empty | Extra ComfyUI arguments |
| `IVBOX_ENABLE_AOTRITON` | `0` | Set to `1` to test AOTriton |
| `HIP_VISIBLE_DEVICES` | `0` | GPU selection |
| `HF_HUB_ENABLE_HF_TRANSFER` | `1` | Faster Hugging Face downloads |
| `HF_XET_HIGH_PERFORMANCE` | `1` | Faster Xet downloads |

The host port is set in `docker-compose.yaml` as `9642:8188`.

The timezone comes from the `/etc/localtime` and `/etc/timezone` mounts.

If a workflow needs different memory behavior, override the flags:

```dotenv
COMFYUI_FLAGS=--bf16-vae --disable-mmap --highvram
```

## Everyday commands

```bash
docker compose up -d
docker compose logs -f ivbox-app
docker compose exec -it ivbox-app bash
docker compose exec ivbox-app ivbox-doctor
docker compose down
```

`ivbox-doctor` checks the GPU, PyTorch/HIP, directories, ComfyUI HTTP, custom
nodes, and storage.

## Updating

```bash
git pull
docker compose build --pull
docker compose up -d
```

Your models, workflows, outputs, and settings stay in the host directories.

## Troubleshooting

### ComfyUI does not start

Check the logs:

```bash
docker compose logs -f ivbox-app
```

### GPU preflight failed

IVBox runs a small GPU allocation check before starting ComfyUI. If it fails,
the container stops instead of restart-looping.

Check that `/dev/kfd` and `/dev/dri` exist on the host and that the container
has access to them. Do not change ComfyUI flags to work around a GPU preflight
failure; the torch/ROCm stack must match the host driver.

### Port already in use

Change the host side of the port mapping in `docker-compose.yaml`:

```yaml
ports:
  - 9642:8188
```

### Models do not show up

Check that your models are in `./comfyui-models` and that the container was
recreated after changing the mount.

### ComfyUI-Manager will not install or update nodes

That is intentional. It runs in offline mode. Edit
`./comfyui/user/__manager/config.ini` if you want to change that behavior.

## Under the hood

IVBox runs on Ubuntu 24.04 with Python 3.12 and a pinned ROCm 7.12 PyTorch
stack for `gfx1151`. The image is built for Strix Halo and is not intended for
other AMD GPUs.

## License

IVBox is licensed under GPLv3. See `LICENSE`.

Third-party components keep their own upstream licenses.
