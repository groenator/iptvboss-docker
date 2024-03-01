#!/bin/bash

if [ -n "$CRONITOR_API_KEY" ]; then
    cronitor discover --auto --api-key "$CRONITOR_API_KEY" &
else
    echo "CRONITOR_API_KEY not set. Please make sure it is defined."
fi

/dockerstartup/vnc_startup.sh --wait
```
