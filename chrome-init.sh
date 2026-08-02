#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

VNC_RES_W=${VNC_RESOLUTION%x*}
VNC_RES_H=${VNC_RESOLUTION#*x}

echo -e "\n------------------ update chromium-browser.init ------------------"
echo -e "\n... set window size $VNC_RES_W x $VNC_RES_H as chrome window size!\n"

# Upstream (ConSol/docker-headless-vnc-container) ships this file with a bare
# `--user-data-dir` flag (no `=value`). Newer Chromium (150.x on trixie) does
# not tolerate that: the browser process starts but never spawns a GPU or
# renderer process, so no window ever appears. Give it a real profile path.
mkdir -p "$HOME/.config/chromium-browser"

echo "export CHROMIUM_FLAGS='--no-sandbox --test-type --start-maximized --disable-gpu --disable-dev-shm-usage --user-data-dir=$HOME/.config/chromium-browser --window-size=$VNC_RES_W,$VNC_RES_H --window-position=0,0'" > $HOME/.chromium-browser.init
