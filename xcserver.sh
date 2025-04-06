#!/bin/bash

set -xe

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

    # Change to iptvboss user for user-level commands
    exec gosu iptvboss "$BASH_SOURCE" "$@"
fi

# The following will run as iptvboss user due to gosu command above
if [ -n "$CRON_SCHEDULE" ]; then
    # Function to update cron job schedule based on the provided environment variable
    update_cron_schedule() {
        CRON_SCHEDULE="${1:-0 04-17/12 * * *}"  # Default schedule if not provided
        crontab -r
        sed -i -e "s|.*iptvboss.*|${CRON_SCHEDULE} /usr/lib/iptvboss/bin/iptvboss -nogui >> /var/log/cron.log|" /headless/iptvboss-cron
        crontab /headless/iptvboss-cron
    }

    update_cron_schedule "$CRON_SCHEDULE"
    echo "CRON_SCHEDULE set for $CRON_SCHEDULE as defined. Updated the cron job schedule."
else
    echo "CRON_SCHEDULE not set. Using default schedule."
fi

# Configure cronitor if API key is provided
if [ -n "$CRONITOR_API_KEY" ]; then
    configure_cronitor() {
        python3 /headless/scripts/cronitor.py --name "$CRONITOR_SCHEDULE_NAME"
    }
    configure_cronitor
fi

# # Start XCServer on Boot
# if [ "$XC_SERVER" = "true" ]; then
#     echo "Starting XCServer..."
#     /usr/bin/iptvboss -xcserver &
#     echo "XCServer started successfully..."
# else
#     echo "XC_SERVER is not set to true. XCServer will not be started."
# fi
echo "Debug: Attempting to start /usr/bin/iptvboss -xcserver..."
/usr/bin/iptvboss -xcserver
if [ $? -eq 0 ]; then
    echo "Debug: /usr/bin/iptvboss -xcserver started successfully."
else
    echo "Error: Failed to start /usr/bin/iptvboss -xcserver." >&2
fi
