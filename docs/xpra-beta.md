# IPTVBoss Xpra - Beta

Please note this is a beta image and may contain bugs. Back up your IPTVBoss data before using it.

`Beta` here refers to the IPTVBoss app release channel. This image tracks official IPTVBoss beta releases (from the `beta-release` tag/file), not a separate "beta container" codebase.

This image uses the same Xpra setup as [Xpra stable](xpra-stable.md), but tracks the IPTVBoss beta release.

## Why this image exists

- The older VNC base stack has been harder to maintain because upstream updates have been slow.
- Keeping that path buildable required manual Debian repository workarounds during updates.
- Running a full XFCE desktop just to use IPTVBoss is heavier than needed for many users.
- This Xpra image keeps GUI access simple and lightweight: browser window + IPTVBoss + helper apps.

- Image: `ghcr.io/groenator/iptvboss-xpra-beta:<version>`
- Ports: `5454` (Xpra WebSocket / HTML5 client)
- Data volume: `/headless/IPTVBoss`

## Docker Compose

Cronitor variables are optional. Include them only if you want Cronitor monitoring.
Cronitor is used to monitor cron job runs and alert on failures. To enable it, create an account at [Cronitor.io](https://cronitor.io) and use your API key.
Use `CRON_SCHEDULE` only for container-managed cron scheduling. If you use IPTVBoss internal scheduling instead, leave `CRON_SCHEDULE` unset; Cronitor cannot monitor IPTVBoss internal scheduling.

```yaml
services:
  iptvboss-xpra-beta:
    image: ghcr.io/groenator/iptvboss-xpra-beta:<version> # The image has support for both ARM and x86 devices.
    environment:
      PUID: "1000" # Set the user ID for the container.
      PGID: "1000" # Set the group ID for the container.
      TZ: "US/Eastern" # Set the timezone for the container.
      CRON_SCHEDULE: "0 0 * * *" # Optional: set only when using container-managed cron scheduling.
      CRONITOR_API_KEY: "<your_cronitor_api_key>" # Optional: required only for Cronitor monitoring.
      CRONITOR_SCHEDULE_NAME: "My IPTVBoss Job" # Optional: custom Cronitor monitor name.
    ports:
    - 5454:5454 # Used by Xpra WebSocket / HTML5 client.
    volumes:
    # Replace <local_volume> with the local directory where you want to store IPTVBoss data.
    # Based on the PUID and PGID environment variables the folder permissions are set at runtime.
    - <local_volume>:/headless/IPTVBoss
```

Start:

```bash
docker-compose up -d
```

## Docker CLI

Cronitor variables are optional. Remove them if you do not use Cronitor.

```bash
docker run -it --rm \
    --name iptvboss-xpra-beta \
    -p 5454:5454 \
    -e PUID=1000 -e PGID=1000 \
    -e TZ=US/Eastern \
    -e CRON_SCHEDULE="0 0 * * *" \
    -e CRONITOR_API_KEY="<your_cronitor_api_key>" \
    -e CRONITOR_SCHEDULE_NAME="My IPTVBoss Job" \
    -v <your-local-volume>:/headless/IPTVBoss \
    ghcr.io/groenator/iptvboss-xpra-beta:<version>
```

## Access Xpra and launch IPTVBoss

1. Open `http://your-host-ip:5454` in your browser.
2. In the Xpra top menu, click Applications -> IPTVBoss.
3. If needed, open Applications -> Terminal for shell access.

## Build locally

```bash
docker build -f Dockerfile.xpra \
    --build-arg BETA_TAG=<iptvboss-beta-tag> \
    -t iptvboss-xpra:beta .
```

Everything else (menu launch behavior, cron setup, volume permissions, Cronitor integration) is the same as [Xpra stable](xpra-stable.md).
