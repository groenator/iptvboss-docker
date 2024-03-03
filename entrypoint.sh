#!/bin/bash

if [ -n "$CRONITOR_API_KEY" ]; then
    cronitor discover --auto --api-key "$CRONITOR_API_KEY" &
else
    echo "CRONITOR_API_KEY not set. Skiping cronitor configuration."
fi

echo "start cron daemon"
cron &
echo "cron daemon started"

echo "start vnc service"
/dockerstartup/vnc_startup.sh --wait
echo "vnc service started successfully"
```
