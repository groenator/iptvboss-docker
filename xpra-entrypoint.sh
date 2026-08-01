#!/bin/bash
set -e

# Root-level setup: permissions and cron daemon, then drop to iptvboss user (mirrors entrypoint.sh/xcserver.sh).
if [ "$(id -u)" = "0" ]; then
    if [ -n "${PUID}" ] && [ -n "${PGID}" ]; then
        echo "Setting iptvboss user and group id to ${PUID} and ${PGID}..."
        groupmod -o -g "${PGID}" iptvboss
        usermod -o -u "${PUID}" iptvboss
        chown -R "${PUID}:${PGID}" /headless
    fi

    echo "Starting the cron daemon"
    cron

    touch /headless/iptvboss-cron && \
    chown iptvboss:iptvboss /headless/iptvboss-cron && \
    chmod 600 /headless/iptvboss-cron && \
    crontab -u iptvboss /headless/iptvboss-cron 2>/dev/null || true
    touch /headless/IPTVBoss/log/cron.log
    chown iptvboss:iptvboss /headless/IPTVBoss/log/cron.log

    exec gosu iptvboss "$BASH_SOURCE" "$@"
fi

# The following runs as the app user due to the gosu re-exec above.
/usr/local/bin/configure_cron_schedule.sh

if [ -n "$CRONITOR_API_KEY" ]; then
    python3 /usr/local/bin/cronitor.py --name "${CRONITOR_SCHEDULE_NAME:-IPTVBoss Cron}"
fi

mkdir -p /run/xpra
export XDG_RUNTIME_DIR=/tmp
export HOME=/headless
# gnome-terminal requires a UTF-8 locale.
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"
exec xpra start \
    --daemon=no \
    --bind-ws=0.0.0.0:5454 \
    --resize-display=yes \
    --start-child-on-connect="sh -lc 'pgrep -f /usr/lib/iptvboss/bin/iptvboss >/dev/null || exec /usr/bin/iptvboss'" \
    :100
