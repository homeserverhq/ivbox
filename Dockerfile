FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG COMFYUI_REF=v0.42.5
ARG ROCM_WHEEL_INDEX=https://rocm.nightlies.amd.com/v2-staging/gfx1151/

ENV VIRTUAL_ENV=/opt/venv \
    PATH=/opt/venv/bin:$PATH \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    HF_HOME=/root/.cache/huggingface

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3.12 \
        python3.12-venv \
        python3.12-dev \
        python3-pip \
        build-essential \
        git \
        curl \
        ca-certificates \
        rsync \
        pkg-config \
        cmake \
        ninja-build \
        libdrm2 \
        libdrm-dev \
        libnuma1 \
        libelf1t64 \
        libpciaccess0 \
        libudev1 \
        libgomp1 \
        libatomic1 \
        ffmpeg \
        sox \
        libsox-dev \
        libsndfile1 \
        libsndfile1-dev \
        libportaudio2 \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libswscale-dev \
        libavfilter-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libwebp-dev \
        libssl-dev \
        libffi-dev \
        libsqlite3-dev \
        libbz2-dev \
        liblzma-dev \
        zlib1g-dev \
        fontconfig \
        fonts-dejavu-core \
        fonts-cantarell \
        libgl1 \
        libglib2.0-0t64 \
        libsm6 \
        libxext6 \
        libxrender1 \
        vim \
        dialog \
        procps \
        iproute2 \
        pciutils \
        unzip \
        xz-utils \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN python3.12 -m venv /opt/venv \
    && python -m pip install --upgrade pip setuptools wheel

COPY requirements /tmp/requirements

RUN python -m pip install \
        --index-url "${ROCM_WHEEL_INDEX}" \
        -r /tmp/requirements/rocm.lock

RUN python -m pip install \
        --index-url "${ROCM_WHEEL_INDEX}" \
        --pre \
        -r /tmp/requirements/torch.lock

RUN (python -m pip freeze | grep -E '^(torch|torchvision|torchaudio)==' > /tmp/torch-constraints.txt) || true

WORKDIR /opt

RUN git clone --depth=1 --branch "${COMFYUI_REF}" \
        https://github.com/comfyanonymous/ComfyUI.git /opt/ComfyUI

WORKDIR /opt/ComfyUI

RUN python -m pip install \
        -c /tmp/torch-constraints.txt \
        -r /opt/ComfyUI/requirements.txt

RUN python -m pip install \
        -c /tmp/torch-constraints.txt \
        -r /tmp/requirements/nodes/core.txt \
        -r /tmp/requirements/nodes/manager.txt \
        -r /tmp/requirements/nodes/gguf.txt \
        -r /tmp/requirements/nodes/impact.txt \
        -r /tmp/requirements/nodes/kjnodes.txt \
        -r /tmp/requirements/nodes/audio.txt \
        -r /tmp/requirements/nodes/mtb.txt \
        -r /tmp/requirements/nodes/easyuse.txt \
        -r /tmp/requirements/nodes/controlnet.txt \
        -r /tmp/requirements/nodes/misc.txt

RUN mkdir -p /opt/ivbox/custom_nodes

RUN git clone --depth=1 https://github.com/ltdrdata/ComfyUI-Manager.git /opt/ivbox/custom_nodes/ComfyUI-Manager
RUN git clone --depth=1 https://github.com/cubiq/ComfyUI_essentials.git /opt/ivbox/custom_nodes/ComfyUI_essentials
RUN git clone --depth=1 https://github.com/kyuz0/ComfyUI-AMDGPUMonitor.git /opt/ivbox/custom_nodes/ComfyUI-AMDGPUMonitor
RUN git clone --depth=1 https://github.com/evanspearman/ComfyMath.git /opt/ivbox/custom_nodes/ComfyMath
RUN git clone --depth=1 https://github.com/kyuz0/ComfyUI-GGUF-H3.git /opt/ivbox/custom_nodes/ComfyUI-GGUF-H3
RUN git clone --depth=1 https://github.com/ltdrdata/ComfyUI-Impact-Pack.git /opt/ivbox/custom_nodes/ComfyUI-Impact-Pack
RUN git clone --depth=1 https://github.com/kijai/ComfyUI-KJNodes.git /opt/ivbox/custom_nodes/ComfyUI-KJNodes
RUN git clone --depth=1 https://github.com/kijai/ComfyUI-MelBandRoFormer.git /opt/ivbox/custom_nodes/ComfyUI-MelBandRoFormer
RUN git clone --depth=1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /opt/ivbox/custom_nodes/ComfyUI-VideoHelperSuite
RUN git clone --depth=1 https://github.com/1038lab/ComfyUI-VoxCPMTTS.git /opt/ivbox/custom_nodes/ComfyUI-VoxCPMTTS
RUN git clone --depth=1 https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git /opt/ivbox/custom_nodes/ComfyUI_Comfyroll_CustomNodes
RUN git clone --depth=1 https://github.com/melMass/comfy_mtb.git /opt/ivbox/custom_nodes/comfy_mtb
RUN git clone --depth=1 https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git /opt/ivbox/custom_nodes/ComfyUI-Advanced-ControlNet
RUN git clone --depth=1 https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git /opt/ivbox/custom_nodes/ComfyUI-Custom-Scripts
RUN git clone --depth=1 https://github.com/yolain/ComfyUI-Easy-Use.git /opt/ivbox/custom_nodes/ComfyUI-Easy-Use
RUN git clone --depth=1 https://github.com/Fannovel16/comfyui_controlnet_aux.git /opt/ivbox/custom_nodes/comfyui_controlnet_aux
RUN git clone --depth=1 https://github.com/lldacing/ComfyUI_Patches_ll.git /opt/ivbox/custom_nodes/ComfyUI_Patches_ll
RUN git clone --depth=1 https://github.com/calcuis/gguf.git /opt/ivbox/custom_nodes/gguf
RUN git clone --depth=1 https://github.com/rgthree/rgthree-comfy.git /opt/ivbox/custom_nodes/rgthree-comfy
RUN git clone --depth=1 https://github.com/Larryvrh/ComfyUI-MiniMax-H3-Turbo.git /opt/ivbox/custom_nodes/ComfyUI-MiniMax-H3-Turbo

COPY defaults /opt/ivbox/defaults
COPY scripts /opt/ivbox/scripts
COPY workflows /opt/ivbox/workflows

RUN chmod 0755 /opt/ivbox/scripts/*.sh /opt/ivbox/scripts/ivbox-doctor /opt/ivbox/scripts/model_manager.py /opt/ivbox/scripts/verify_models.py /opt/ivbox/scripts/gpu_check.py \
    && ln -s /opt/ivbox/scripts/start_docker.sh /opt/start_docker.sh \
    && ln -s /opt/ivbox/scripts/ivbox-doctor /usr/local/bin/ivbox-doctor \
    && ln -s /opt/ivbox/scripts/model_manager.py /usr/local/bin/model_manager \
    && ln -s /opt/ivbox/scripts/verify_models.py /usr/local/bin/ivbox-verify-models \
    && cp /opt/ivbox/scripts/99-banner.sh /etc/profile.d/99-ivbox-banner.sh \
    && cp /opt/ivbox/scripts/zz-venv-last.sh /etc/profile.d/zz-venv-last.sh \
    && chmod 0644 /etc/profile.d/99-ivbox-banner.sh /etc/profile.d/zz-venv-last.sh

RUN find /opt/venv -type d -name '__pycache__' -prune -exec rm -rf {} + \
    && (python -m pip cache purge || true) \
    && rm -rf /root/.cache/pip

RUN python -c 'import torch; print("torch", torch.__version__)' \
    && python -m pip check

EXPOSE 8188

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD curl -fsS http://127.0.0.1:8188/ >/dev/null || exit 1

STOPSIGNAL SIGTERM

CMD ["/opt/start_docker.sh"]
