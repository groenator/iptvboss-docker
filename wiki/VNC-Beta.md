# IPTVBoss VNC — Beta

**Please note that this is a beta release and may contain bugs.** It is highly recommended to back up your IPTVBoss data before using the beta version.

`Beta` here refers to the IPTVBoss app release channel. This image tracks official IPTVBoss beta releases (from the `beta-release` tag/file), not a separate "beta container" codebase.

The beta VNC image is built from the same [`Dockerfile`](https://github.com/groenator/iptvboss-docker/blob/master/Dockerfile) as the [stable VNC image](VNC-Stable) — same desktop environment, same VNC/noVNC ports, same environment variables — but tracks a beta release tag of IPTVBoss instead of the latest stable release.

- Image: `ghcr.io/groenator/iptvboss-docker-beta:<version>`
- Ports: `5901` (VNC client), `6901` (noVNC web client), `8001` (XC server, optional)
- Data volume: `/headless/IPTVBoss`

## Docker Compose

Replace the `image` field in your docker-compose file with the beta image and a specific `<version>` tag:

```yaml
services:
  iptvboss:
    image: ghcr.io/groenator/iptvboss-docker-beta:<version> # Use the beta image with tag
    environment:
      PUID: "1000" # Set the user ID for the container.
      PGID: "1000" # Set the group ID for the container.
      TZ: "US/Eastern" # Set the timezone for the container.
      CRON_SCHEDULE: "0 0 * * *" # Optional: set only when using container-managed cron scheduling.
      CRONITOR_API_KEY: "<your_cronitor_api_key>" # Optional: required only for Cronitor monitoring.
      CRONITOR_SCHEDULE_NAME: "My IPTVBoss Job" # Optional: custom Cronitor monitor name.
      XC_SERVER: "true"
    ports:
      - 8001:8001 # Used by XC Server
      - 5901:5901 # Used by the VNC Server to connect to the container using the VNC client.
      - 6901:6901 # Used by the VNC Server to connect to the container using a web browser.
    volumes:
    # Replace <local_volume> with the local directory where you want to store the IPTVBoss data. E.g., /home/user/iptvboss.
    # Based on the PUID and PGID environment variables the folder permissions are set at runtime.
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
    -e CRONITOR_API_KEY="<your_cronitor_api_key>" \
    -e CRONITOR_SCHEDULE_NAME="My IPTVBoss Job" \
    -e TZ=US/Eastern -e XC_SERVER=true \
    -v <your-local-volume>:/headless/IPTVBoss \
    ghcr.io/groenator/iptvboss-docker-beta:<version>
```

## Everything else is the same as stable

Accessing the VNC server, the full noVNC client/clipboard, overriding VNC environment variables, Dropbox/Firefox default browser, the desktop launcher trust prompt, and Cronitor integration all work identically to the stable image. See [VNC — Stable](VNC-Stable) for those details.
