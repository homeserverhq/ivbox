#!/usr/bin/env bash

if [ "${IVBOX_ENABLE_AOTRITON:-0}" = "1" ]; then
    export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
else
    export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=0
fi

export TORCH_BLAS_PREFER_HIPBLASLT="${TORCH_BLAS_PREFER_HIPBLASLT:-1}"
export HF_HOME="${HF_HOME:-/root/.cache/huggingface}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/comfyui/cache}"
export PYTHONUNBUFFERED=1
