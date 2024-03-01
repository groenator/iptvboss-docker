#!/bin/bash

# Function to configure and discover Cronitor
configure_cronitor() {
    if [ "$CRONITOR_ENABLE" = "true" ] && [ -n "$CRONITOR_API_KEY" ]; then
        echo "{ \"CRONITOR_API_KEY\": \"$CRONITOR_API_KEY\" }" > /etc/cronitor/cronitor.json
        cronitor discover --auto
    fi
}

# Run the Cronitor configuration and discovery function
configure_cronitor

# Start the VNC server or any other startup commands
exec "$@"
