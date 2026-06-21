#!/bin/bash
set -e

CRON_FILE="${CRON_FILE:-/headless/iptvboss-cron}"
CRON_JOB_MARKER="${CRON_JOB_MARKER:-iptvboss -nogui}"
CRON_TARGET_CMD="${CRON_TARGET_CMD:-/usr/lib/iptvboss/bin/iptvboss -nogui >> /var/log/cron.log 2>&1}"

if [ -z "$CRON_SCHEDULE" ]; then
    echo "CRON_SCHEDULE not set. No cron job configured for iptvboss."
    exit 0
fi

echo "Configuring Cron schedule for iptvboss user..."
CRON_LINE="$CRON_SCHEDULE $CRON_TARGET_CMD"

# Ensure cron file exists before searching/updating.
touch "$CRON_FILE"

if grep -q "$CRON_JOB_MARKER" "$CRON_FILE" 2>/dev/null; then
    echo "Found existing iptvboss cron entry. Rewriting cron line..."
    TMP_CRON_FILE="$(mktemp)"
    grep -v "$CRON_JOB_MARKER" "$CRON_FILE" > "$TMP_CRON_FILE" || true
    printf '%s\n' "$CRON_LINE" >> "$TMP_CRON_FILE"
    mv "$TMP_CRON_FILE" "$CRON_FILE"
else
    echo "No existing iptvboss cron entry found. Appending new cron line..."
    printf '%s\n' "$CRON_LINE" >> "$CRON_FILE"
fi

echo "Current $CRON_FILE contents:"
cat "$CRON_FILE"

if [ "${APPLY_CRONTAB:-1}" = "1" ]; then
    crontab "$CRON_FILE"
    echo "CRON_SCHEDULE set for $CRON_SCHEDULE. Updated the cron job schedule."
else
    echo "APPLY_CRONTAB=0 set. Skipping crontab install."
fi

