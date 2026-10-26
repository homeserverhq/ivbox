#!/usr/bin/env bash

cat <<'EOF'

  _  _ __   __ ____   _____  __
 | || |\ \ / /| __ ) / _ \ \/ /
 | || |_\ V / |  _ \| | | \  /
 |__   _|| |  | |_) | |_| /  \
    |_|  |_|  |____/ \___/_/\_\

 ComfyUI appliance shell
 ------------------------
 Start server : /opt/start_docker.sh
 Doctor       : ivbox-doctor
 Models       : /comfyui/models
 Output       : /comfyui/output
 Workflows    : /comfyui/user/default/workflows
EOF
