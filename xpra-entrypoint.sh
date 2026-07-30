#!/bin/bash
set -e

# Root-level setup: permissions and cron daemon, then drop to app user (mirrors entrypoint.sh/xcserver.sh).
if [ "$(id -u)" = "0" ]; then
    if [ -n "${PUID}" ] && [ -n "${PGID}" ]; then
        echo "Setting app user and group id to ${PUID} and ${PGID}..."
        groupmod -o -g "${PGID}" app
        usermod -o -u "${PUID}" app
        chown -R "${PUID}:${PGID}" /config
    fi

    echo "Starting the cron daemon"
    cron

    crontab -u app /config/iptvboss-cron 2>/dev/null || true
    touch /config/log/cron.log
    chown app:app /config/log/cron.log

    exec gosu app "$BASH_SOURCE" "$@"
fi

# The following runs as the app user due to the gosu re-exec above.
/usr/local/bin/configure_cron_schedule.sh

if [ -n "$CRONITOR_API_KEY" ]; then
    python3 /usr/local/bin/cronitor.py --name "${CRONITOR_SCHEDULE_NAME:-IPTVBoss Cron}"
fi

mkdir -p /run/xpra
export XDG_RUNTIME_DIR=/tmp
exec xpra start \
    --daemon=no \
    --bind-ws=0.0.0.0:5454 \
    --resize-display=yes \
    --start-child-on-connect="sh -lc 'pgrep -f /usr/lib/iptvboss/bin/iptvboss >/dev/null || exec /usr/bin/iptvboss'" \
    :100
