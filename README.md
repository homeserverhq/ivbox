# IVBox

IVBox is a ComfyUI appliance image for AMD Strix Halo systems (`gfx1151`).
It uses Ubuntu 24.04, Python 3.12, and TheRock `gfx1151` PyTorch wheels.

The image runs ComfyUI only. It does not include Qwen Image Studio, Wan Video
Studio, or a flash-attention build.

## Host layout

All persistent data lives under `./comfyui` next to this file:

```text
comfyui/
├── models/
├── input/
├── output/
├── user/
├── custom_nodes/
├── cache/
├── temp/
├── previews/
├── datasets/
└── huggingface/
```

The container maps these paths as `/comfyui/models`, `/comfyui/input`,
`/comfyui/output`, `/comfyui/user`, `/comfyui/custom_nodes`,
`/comfyui/cache`, `/comfyui/temp`, `/comfyui/previews`,
`/comfyui/datasets`, and `/root/.cache/huggingface`.

## Build

```bash
cp stack.env.example stack.env
docker compose build
docker compose up -d
```

ComfyUI is exposed on port `9642`:

```text
http://localhost:9642/
```

## Configuration

`stack.env` supports:

```dotenv
HIP_VISIBLE_DEVICES=0
HF_HUB_ENABLE_HF_TRANSFER=1
HF_XET_HIGH_PERFORMANCE=1
COMFYUI_PORT=8188
TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
TORCH_BLAS_PREFER_HIPBLASLT=1
COMFYUI_FLAGS=
COMFYUI_ARGS=
```

`COMFYUI_FLAGS` empty uses:

```text
--bf16-vae --disable-mmap --gpu-only --disable-smart-memory --cache-none
```

Override it if a workflow needs different memory behavior:

```dotenv
COMFYUI_FLAGS=--bf16-vae --disable-mmap
```

The timezone comes from the `/etc/localtime` and `/etc/timezone` mounts.

## Custom nodes

The image bakes these nodes into `/opt/ivbox/custom_nodes`:

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

At startup, baked nodes are symlinked into `./comfyui/custom_nodes`. Nodes you
place there yourself take precedence over a baked node with the same name.

ComfyUI-Manager is configured for offline mode so it does not update nodes at
startup. Edit `./comfyui/user/__manager/config.ini` to change it.

## Models

Models are never baked into the image. Put them under `./comfyui/models`.

The helper can download OSI-licensed model sets:

```bash
docker exec -it ivbox-app model_manager list
docker exec -it ivbox-app model_manager download qwen-image qwen-image-edit
docker exec -it ivbox-app model_manager download wan-t2v wan-i2v
docker exec -it ivbox-app model_manager verify
```

Model downloads use the Hugging Face cache mapped to
`./comfyui/huggingface`.

## Workflows

Put workflows in:

```text
./comfyui/user/default/workflows/
```

Image-baked default workflows are seeded there on first start only. Existing
files are never overwritten.

## Commands

```bash
docker compose up -d
docker compose logs -f
docker exec -it ivbox-app bash
docker exec -it ivbox-app ivbox-doctor
docker compose down
```

`ivbox-doctor` checks devices, directories, PyTorch/HIP, ComfyUI HTTP, custom
nodes, and storage.

## License

IVBox is licensed under GPLv3. See `LICENSE`.

Third-party components keep their own upstream licenses.
