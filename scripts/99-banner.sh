#!/usr/bin/env bash

cat <<'EOF'

 ___    __      __    ____      ___    __  __
|_ _|   \ \    / /   | __ )    / _ \   \ \/ /
 | |     \ \  / /    |  _ \   | | | |   \  /
 | |      \ \/ /     | |_) |  | |_| |   /  \
|___|      \__/      |____/    \___/   /_/\_\

 ComfyUI appliance shell
 ------------------------
 Start server : /opt/start_docker.sh
 Doctor       : ivbox-doctor
 Models       : /comfyui/models
 Output       : /comfyui/output
 Workflows    : /comfyui/user/default/workflows
EOF
