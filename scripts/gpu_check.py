#!/usr/bin/env python3
"""Fail fast when the PyTorch/ROCm stack cannot allocate on the GPU."""

from __future__ import annotations

import sys

import torch

print(f"torch={torch.__version__}", flush=True)
print(f"hip={torch.version.hip}", flush=True)

if not torch.cuda.is_available():
    print("gpu_check: torch.cuda.is_available() is False", file=sys.stderr, flush=True)
    raise SystemExit(1)

print(f"device={torch.cuda.get_device_name(0)}", flush=True)
print(f"arch={torch.cuda.get_device_properties(0).gcnArchName}", flush=True)

x = torch.zeros(1, device="cuda")
torch.cuda.synchronize()
print(f"gpu_allocation_ok={x.item()}", flush=True)
