#!/bin/bash

# Function to update cron job schedule based on the provided environment variable
update_cron_schedule() {
    CRON_SCHEDULE="${1:-0 04-17/12 * * *}"  # Default schedule if not provided
    crontab -r -u iptvboss
    sed -i -e "s|.*iptvboss.*|${CRON_SCHEDULE} /usr/lib/iptvboss/bin/iptvboss -nogui >> /var/log/cron.log|" /headless/iptvboss-cron
    crontab -u iptvboss /headless/iptvboss-cron
}

if [ -n "$CRONITOR_API_KEY" ]; then
    cronitor discover --auto --api-key "$CRONITOR_API_KEY" &
else
    echo "CRONITOR_API_KEY not set. Skiping cronitor configuration."
fi

# Update the cron job schedule based on the environment variable
if [ -n "$CRON_SCHEDULE" ]; then
    update_cron_schedule "$CRON_SCHEDULE"
    echo "CRON_SCHEDULE set for $CRON_SCHEDULE defined. Updated the cron job schedule."
else
    echo "CRON_SCHEDULE not set. Using default schedule."
fi

echo "start cron daemon"
cron &
echo "cron daemon started"

echo "start vnc service"
/dockerstartup/vnc_startup.sh --wait
echo "vnc service started successfully"
```
