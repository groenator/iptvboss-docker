#!/usr/bin/env bash
# gio's metadata::trusted attribute is backed by gvfsd-metadata over the
# session D-Bus connection. That service isn't up yet when entrypoint.sh runs
# (it starts as part of the XFCE session), so setting trust there always fails
# with "not supported". Run this as an XFCE autostart entry instead, once the
# desktop session (and gvfsd-metadata) is actually running.
for i in $(seq 1 15); do
    if gio info -a metadata::trusted "$HOME/Desktop" >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

shopt -s nullglob
for desktop_file in "$HOME"/Desktop/*.desktop; do
    gio set "$desktop_file" metadata::trusted true 2>/dev/null
done
