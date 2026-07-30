# IPTVBoss Headless — Stable

`Dockerfile.headless` builds a lightweight, Ubuntu-based image that runs only the IPTVBoss XC server and its cron-driven EPG update job — there is no VNC server, no desktop environment, and no GUI. Use this variant if you only need the XC server API/stream endpoints and don't need to interact with the IPTVBoss desktop application at all.

`Stable` here refers to the IPTVBoss app release channel. This image tracks official non-beta IPTVBoss releases (from the `release` tag/file), not a separate "stable container" codebase.

- Built locally from [`Dockerfile.headless`](../Dockerfile.headless) (no pre-built registry image — build it yourself with the `LATEST_TAG` build arg)
- Ports: `8001` (XC server) only — there are no VNC ports for this image

**Note:**

- *`PUID`/`PGID`, `CRON_SCHEDULE`, `TZ`, `CRONITOR_API_KEY` and `CRONITOR_SCHEDULE_NAME` all behave the same way as the [VNC image](vnc-stable.md).*
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
    build:
      context: .
      dockerfile: Dockerfile.headless
      args:
        LATEST_TAG: <iptvboss-release-tag>
    environment:
      PUID: "1000"
      PGID: "1000"
      TZ: "US/Eastern"
      CRON_SCHEDULE: "0 0 * * *"
    ports:
      - 8001:8001 # Used by XC Server
    volumes:
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
    -e TZ=US/Eastern \
    -v <your-local-volume>:/headless/IPTVBoss \
    iptvboss-headless
```

Access the XC server at `http://<your-machine-ip>:8001`.

See also: [Cronitor integration](cronitor.md).
