# IPTVBoss VNC — Beta

**Please note that this is a beta release and may contain bugs.** It is highly recommended to back up your IPTVBoss data before using the beta version.

The beta VNC image is built from the same [`Dockerfile`](../Dockerfile) as the [stable VNC image](vnc-stable.md) — same desktop environment, same VNC/noVNC ports, same environment variables — but tracks a beta release tag of IPTVBoss instead of the latest stable release.

- Image: `ghcr.io/groenator/iptvboss-docker-beta:<version>`
- Ports: `5901` (VNC client), `6901` (noVNC web client), `8001` (XC server, optional)

## Docker Compose

Replace the `image` field in your docker-compose file with the beta image and a specific `<version>` tag:

```yaml
services:
  iptvboss:
    image: ghcr.io/groenator/iptvboss-docker-beta:<version> # Use the beta image with tag
    environment:
      PUID: "1000"
      PGID: "1000"
      TZ: "US/Eastern"
      CRON_SCHEDULE: "0 0 * * *"
      XC_SERVER: "true"
    ports:
      - 8001:8001
      - 5901:5901
      - 6901:6901
    volumes:
      - <local_volume>:/headless/IPTVBoss
```

```bash
docker-compose up -d
```

## Docker CLI

```bash
docker run -it -p 5901:5901 -p 6901:6901 -p 8001:8001 \
    --name iptvboss \
    -e PUID=1000 -e PGID=1000 \
    -e CRON_SCHEDULE="* * * * *" \
    -e TZ=US/Eastern -e XC_SERVER=true \
    -v <your-local-volume>:/headless/IPTVBoss \
    ghcr.io/groenator/iptvboss-docker-beta:<version>
```

## Everything else is the same as stable

Accessing the VNC server, the full noVNC client/clipboard, overriding VNC environment variables, Dropbox/Firefox default browser, the desktop launcher trust prompt, and Cronitor integration all work identically to the stable image. See [VNC — Stable](vnc-stable.md) for those details.
