#!/bin/bash
set -e
# Run as root to install cronitor and set permissions
if [ "$(id -u)" = "0" ]; then
    # Set the uid and gid based on environment variables PUID/PGID
    if [ -n "${PUID}" ] && [ -n "${PGID}" ]; then
        echo "Setting iptvboss user and group id to ${PUID} and ${PGID}..."
        groupmod -o -g "${PGID}" iptvboss
        usermod -o -u "${PUID}" iptvboss
        usermod -aG audio iptvboss
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
    # Give execution rights on the cron job
    crontab -u iptvboss /headless/iptvboss-cron &&  \
    chmod u+s /usr/sbin/cron && \
    touch /var/log/cron.log && \
    chown iptvboss:iptvboss /var/log/cron.log
# Set Mozilla Firefox as the default browser for XFCE/XDG when no user preference exists.
# This helps external authorization links, such as Dropbox auth links, open correctly.
FIREFOX_CMD="$(command -v firefox || command -v firefox-esr || true)"

if [ -n "$FIREFOX_CMD" ]; then
  mkdir -p /headless/.config/xfce4
  mkdir -p /headless/.config
  mkdir -p /headless/.local/share/applications

  if [ ! -f /headless/.config/xfce4/helpers.rc ] || ! grep -q '^WebBrowser=' /headless/.config/xfce4/helpers.rc; then
    echo "Setting Mozilla Firefox as the default XFCE web browser..."
    printf 'WebBrowser=firefox\n' > /headless/.config/xfce4/helpers.rc
  fi

  if [ ! -f /headless/.local/share/applications/firefox.desktop ]; then
    echo "Creating Mozilla Firefox XDG desktop entry..."
    cat > /headless/.local/share/applications/firefox.desktop <<EOF2
[Desktop Entry]
Type=Application
Name=Mozilla Firefox
Exec=$FIREFOX_CMD %U
Icon=firefox
Terminal=false
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
EOF2
  fi

  if [ ! -f /headless/.config/mimeapps.list ]; then
    echo "Setting Mozilla Firefox as the default XDG handler for web links..."
    cat > /headless/.config/mimeapps.list <<'EOF2'
[Default Applications]
text/html=firefox.desktop
text/xml=firefox.desktop
application/xhtml+xml=firefox.desktop
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop

[Added Associations]
text/html=firefox.desktop;
text/xml=firefox.desktop;
application/xhtml+xml=firefox.desktop;
x-scheme-handler/http=firefox.desktop;
x-scheme-handler/https=firefox.desktop;
EOF2
  fi
else
  echo "Mozilla Firefox command not found. Skipping default browser setup."
fi

    # Fix XFCE trust for desktop executable files (fixes "Untrusted application launcher" dialog)
    # See: https://github.com/groenator/iptvboss-docker/issues/206
    mkdir -p /headless/.config/xfce4/xfconf/xfce-perchannel-xml
    if [ ! -f /headless/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml ]; then
        printf '<?xml version="1.0" encoding="UTF-8"?>\n<channel name="thunar" version="1.0">\n  <property name="misc-exec-shell-scripts-as-executable" type="bool" value="true"/>\n</channel>\n' \
            > /headless/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml
    fi
    # Restore gvfs-metadata trust checksum if it exists from a previous run
    mkdir -p /headless/.local/share/gvfs-metadata
    if [ -f /headless/IPTVBoss/gvfs-metadata-home ]; then
        cp /headless/IPTVBoss/gvfs-metadata-home /headless/.local/share/gvfs-metadata/home
        chmod 600 /headless/.local/share/gvfs-metadata/home
    fi
    chown -R ${PUID}:${PGID} /headless/.config
    chown -R ${PUID}:${PGID} /headless/.local
    # Change to iptvboss user for user-level commands
    exec gosu iptvboss "$BASH_SOURCE" "$@"
fi
# The following will run as iptvboss user due to gosu command above
/headless/scripts/configure_cron_schedule.sh
# Configure cronitor if API key is provided
if [ -n "$CRONITOR_API_KEY" ]; then
    configure_cronitor() {
        python3 /headless/scripts/cronitor.py --name "$CRONITOR_SCHEDULE_NAME"
    }
    configure_cronitor
fi
# # Start XCServer on Boot
if [ "$XC_SERVER" = "true" ]; then
    echo "Starting XCServer..."
    /usr/bin/iptvboss -xcserver &
    echo "XCServer started successfully..."
else
    echo "XC_SERVER is not set to true. XCServer will not be started."
fi
#Start vnc service
sleep 5
echo "Staring The VNC service"
/dockerstartup/vnc_startup.sh --wait
