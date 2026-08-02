# IPTVBoss Headless — Stable

`Dockerfile.headless` builds a lightweight, Ubuntu-based image that runs only the IPTVBoss XC server and its cron-driven EPG update job — there is no VNC server, no desktop environment, and no GUI. Use this variant if you only need the XC server API/stream endpoints and don't need to interact with the IPTVBoss desktop application at all.

`Stable` here refers to the IPTVBoss app release channel. This image tracks official non-beta IPTVBoss releases (from the `release` tag/file), not a separate "stable container" codebase.

- Image: `ghcr.io/groenator/iptvboss-docker-headless-stable:latest`
- Ports: `8001` (XC server) only — there are no VNC ports for this image
- Data volume: `/headless/IPTVBoss`

**Note:**

- *`PUID`/`PGID`, `CRON_SCHEDULE`, `TZ`, `CRONITOR_API_KEY` and `CRONITOR_SCHEDULE_NAME` all behave the same way as the [VNC image](VNC-Stable).*
- *Use `CRON_SCHEDULE` only for container-managed cron scheduling. If you use IPTVBoss internal scheduling instead, leave `CRON_SCHEDULE` unset; Cronitor cannot monitor IPTVBoss internal scheduling.*
- *The volume is still mounted to `/headless/IPTVBoss`, and the same volume-permission requirements apply — do not run the container as root, and make sure the local folder permissions match your `PUID`/`PGID`.*

## Build the image

```bash
docker build -f Dockerfile.headless \
    --build-arg LATEST_TAG=<iptvboss-release-tag> \
    -t iptvboss-headless .
```

## Docker Compose

```yaml
services:
  iptvboss-headless:
    image: ghcr.io/groenator/iptvboss-docker-headless-stable:<version> # The image has support for both ARM and x86 devices.
    environment:
      PUID: "1000" # Set the user ID for the container.
      PGID: "1000" # Set the group ID for the container.
      TZ: "US/Eastern" # Set the timezone for the container.
      CRON_SCHEDULE: "0 0 * * *" # Optional: set only when using container-managed cron scheduling.
      CRONITOR_API_KEY: "<your_cronitor_api_key>" # Optional: required only for Cronitor monitoring.
      CRONITOR_SCHEDULE_NAME: "My IPTVBoss Job" # Optional: custom Cronitor monitor name.
    ports:
      - 8001:8001 # Used by XC Server.
    volumes:
    # Replace <local_volume> with the local directory where you want to store IPTVBoss data.
    # Based on the PUID and PGID environment variables the folder permissions are set at runtime.
    - <local_volume>:/headless/IPTVBoss
```

```bash
docker-compose up -d
```

## Docker CLI

```bash
docker run -it -p 8001:8001 \
    --name iptvboss-headless \
    -e PUID=1000 -e PGID=1000 \
    -e CRON_SCHEDULE="0 0 * * *" \
    -e CRONITOR_API_KEY="<your_cronitor_api_key>" \
    -e CRONITOR_SCHEDULE_NAME="My IPTVBoss Job" \
    -e TZ=US/Eastern \
    -v <your-local-volume>:/headless/IPTVBoss \
  ghcr.io/groenator/iptvboss-docker-headless-stable:latest
```

Access the XC server at `http://<your-machine-ip>:8001`.

See also: [Cronitor Integration](Cronitor-Integration).
