#!/bin/bash

# Start cron daemon and vnc service
echo "start cron daemon"
cron &
echo "cron daemon started"

# Function to update cron job schedule based on the provided environment variable
update_cron_schedule() {
    CRON_SCHEDULE="${1:-0 04-17/12 * * *}"  # Default schedule if not provided
    crontab -r -u iptvboss
    sed -i -e "s|.*iptvboss.*|${CRON_SCHEDULE} /usr/lib/iptvboss/bin/iptvboss -nogui >> /var/log/cron.log|" /headless/iptvboss-cron
    crontab -u iptvboss /headless/iptvboss-cron
}

# Function to configure cronitor
configure_cronitor() {
    python3 /headless/scripts/cronitor.py --name "$CRONITOR_SCHEDULE_NAME"
    if [ $? -eq 0 ]; then
        echo "Cronitor configuration completed successfully."
    else
        echo "Error: Cronitor configuration failed." >&2
    fi
}

# Update the cron job schedule based on the environment variable
if [ -n "$CRON_SCHEDULE" ]; then
    update_cron_schedule "$CRON_SCHEDULE"
    echo "CRON_SCHEDULE set for $CRON_SCHEDULE as defined. Updated the cron job schedule."
else
    echo "CRON_SCHEDULE not set. Using default schedule."
fi

# Configure cronitor
if [ -n "$CRONITOR_API_KEY" ]; then
    configure_cronitor
else
    echo "CRONITOR_API_KEY not set. Skiping cronitor configuration."
fi

#Start vnc service
echo "start vnc service"
/dockerstartup/vnc_startup.sh --wait
echo "vnc service started successfully"
