# Cronitor Integration (Optional)

Applies to all six image variants ([VNC stable](VNC-Stable), [VNC beta](VNC-Beta), [Headless stable](Headless-Stable), [Headless beta](Headless-Beta), [Xpra stable](Xpra-Stable), [Xpra beta](Xpra-Beta)).

Important:

- This integration only monitors the container-managed cron job configured with `CRON_SCHEDULE`.
- If you use IPTVBoss internal scheduling instead, Cronitor will not see or monitor those runs.

Prerequisites:

- A Cronitor account. Sign up at [Cronitor.io](https://cronitor.io).
- A Cronitor API key.

To enable Cronitor monitoring, set the `CRONITOR_API_KEY` environment variable to your Cronitor API key, set `CRONITOR_SCHEDULE_NAME` to a custom name, and set `CRON_SCHEDULE` for the container cron job.

Run it using docker-compose:

```yaml
services:
  iptvboss:
    image: ghcr.io/groenator/iptvboss-docker:latest # The Image has support for both ARM and x86 devices.
    environment:
      PUID: "1000" # Set the user ID for the container.
      PGID: "1000" # Set the group ID for the container.
      CRON_SCHEDULE: "0 0 * * *" # Set the cron schedule for the cron job that will update the EPG data.
      CRONITOR_API_KEY: "<your_cronitor_api_key>"
      CRONITOR_SCHEDULE_NAME: "My Custom Schedule" # Set a name for your Cronitor.io Job
      XC_SERVER: "true" # Set to true to start the XC server on boot. By default the XCSERVER is set to false.
      TZ: "US/Eastern" # Set the timezone for the container.
    ports:
      - 8001:8001 # Used by XC Server
      - 5901:5901 # Used by the VNC Server to connect to the container using the VNC client.
      - 6901:6901 # Used by the VNC Server to connect to the container using a web browser.
    volumes:
    # Replace <local_volume> with the local directory where you want to store the IPTVBoss data. E.g., /home/user/iptvboss.
    # Based on the PUID and PGID environment variables the folder permissions are set at runtime.
    - <local_volume>:/headless/IPTVBoss
```

Run the following command to start the container:

```bash
docker-compose up -d
```

Or using the Docker CLI:

```bash
# Remove the double quotes around CRONITOR_API_KEY value and replace <your_cronitor_api_key> with your actual Cronitor API key.
docker run -it -p 5901:5901 -p 6901:6901 -p 8001:8001 \
    --name iptvboss \
    -e PUID=1000 -e PGID=1000 \
    -e CRONITOR_API_KEY="<your_cronitor_api_key>" \
    -e CRONITOR_SCHEDULE_NAME=MyJob \
    -e CRON_SCHEDULE="* * * * *" \
    -e XC_SERVER=true \
    -v <your-local-volume>:/headless/IPTVBoss \
    ghcr.io/groenator/iptvboss-docker:latest
```

For the headless image, drop the `5901`/`6901` ports and `XC_SERVER` variable as shown in the [headless docs](Headless-Stable) — everything else is the same.
