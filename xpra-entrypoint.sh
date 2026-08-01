#!/bin/bash
set -e

# Run as root to install cronitor and set permissions
if [ "$(id -u)" = "0" ]; then
    # Set the uid and gid based on environment variables PUID/PGID
    if [ -n "${PUID}" ] && [ -n "${PGID}" ]; then
        echo "Setting iptvboss user and group id to ${PUID} and ${PGID}..."
        groupmod -o -g "${PGID}" iptvboss
        usermod -o -u "${PUID}" iptvboss
        chown -R ${PUID}:${PGID} /headless
    else
        echo "PUID or PGID not set. Using default values."
    fi

    # Install cronitor
    if [ -n "$CRONITOR_API_KEY" ]; then
        echo "Installing cronitor..."
        curl -s https://cronitor.io/install-linux?sudo=1 -H "API-KEY: $CRONITOR_API_KEY" | sh > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Cronitor installed successfully."
        else
            echo "Error: Cronitor installation failed." >&2
        fi
    else
        echo "CRONITOR_API_KEY not set. Skipping cronitor installation."
    fi

    # Start cron daemon as root
    echo "Starting the cron daemon"
    cron
    echo "The cron daemon started successfully."

    # Start D-Bus system bus so Xpra can subscribe to power-management events.
    if [ ! -S /run/dbus/system_bus_socket ]; then
        mkdir -p /run/dbus
        dbus-daemon --system --fork 2>/dev/null || true
    fi

    # Give execution rights on the cron job
    crontab -u iptvboss /headless/iptvboss-cron &&  \
    chmod u+s /usr/sbin/cron && \
    touch /var/log/cron.log && \
    chown iptvboss:iptvboss /var/log/cron.log

    # Ensure the runtime directory is owned by the target user so pulseaudio's
    # pactl client can query devices (XDG_RUNTIME_DIR must be user-owned).
    RUNTIME_UID="${PUID:-911}"
    mkdir -p "/run/user/${RUNTIME_UID}" "/tmp/xdg/xpra"
    chown -R "${RUNTIME_UID}:${PGID:-${RUNTIME_UID}}" "/run/user/${RUNTIME_UID}" "/tmp/xdg"
    chmod 700 "/run/user/${RUNTIME_UID}"

    # Prevent pulseaudio clients from trying to autospawn a second daemon.
    # A pulseaudio instance will be started manually before Xpra in user mode.
    mkdir -p /headless/.config/pulse
    cat > /headless/.config/pulse/client.conf <<EOF
autospawn = no
EOF
    chown -R "${RUNTIME_UID}:${PGID:-${RUNTIME_UID}}" /headless/.config/pulse

    # Change to iptvboss user for user-level commands
    exec gosu iptvboss "$BASH_SOURCE" "$@"
fi

# The following will run as iptvboss user due to gosu command above
/headless/scripts/configure_cron_schedule.sh

mkdir -p /run/xpra
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_CONFIG_HOME=/headless/.config
export XDG_CACHE_HOME=/headless/.cache
export HOME=/headless
# gnome-terminal requires a UTF-8 locale.
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"

# Start a dedicated pulseaudio daemon for Xpra speaker forwarding.
# We start it manually (not via "pulseaudio --start") so PULSE_SERVER can be
# set for applications/pactl without confusing the daemon's autospawn logic.
mkdir -p "${XDG_RUNTIME_DIR}/pulse"
pulseaudio -n --daemonize=false --system=false --exit-idle-time=-1 \
    --load=module-suspend-on-idle \
    --load=module-null-sink sink_name=Xpra-Speaker sink_properties=device.description=Xpra-Speaker \
    --load=module-null-sink sink_name=Xpra-Microphone sink_properties=device.description=Xpra-Microphone \
    --load=module-remap-source source_name=Xpra-Mic-Source source_properties=device.description=Xpra-Mic-Source master=Xpra-Microphone.monitor channels=1 \
    --load=module-native-protocol-unix socket="${XDG_RUNTIME_DIR}/pulse/native" auth-cookie-enabled=0 \
    --disable-shm=yes &
sleep 1
export PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native"

exec xpra start \
    --daemon=no \
    --bind-ws=0.0.0.0:5454 \
    --resize-display=yes \
    --speaker=on \
    --microphone=off \
    --pulseaudio=no \
    --start-child-on-connect="sh -lc 'pgrep -f /usr/lib/iptvboss/bin/iptvboss >/dev/null || exec /usr/bin/iptvboss'" \
    :100
