# IPTVBoss Xpra - Stable

The Xpra stable image runs IPTVBoss in a browser using Xpra HTML5 windows (not a full remote desktop).

`Stable` here refers to the IPTVBoss app release channel. This image tracks official non-beta IPTVBoss releases (from the `release` tag/file), not a separate "stable container" codebase.

- Image: `ghcr.io/groenator/iptvboss-xpra-stable:latest`
- Ports: `5454` (Xpra WebSocket / HTML5 client)
- Data volume: `/headless/IPTVBoss`

## Why this image exists

- The older VNC base stack has been harder to maintain because upstream updates have been slow.
- Keeping that path buildable required manual Debian repository workarounds during updates.
- Running a full XFCE desktop just to use IPTVBoss is heavier than needed for many users.
- This Xpra image keeps GUI access simple and lightweight: browser window + IPTVBoss + helper apps.

## Docker Compose

Cronitor variables are optional. Include them only if you want Cronitor monitoring.
Cronitor is used to monitor cron job runs and alert on failures. To enable it, create an account at [Cronitor.io](https://cronitor.io) and use your API key.
Use `CRON_SCHEDULE` only for container-managed cron scheduling. If you use IPTVBoss internal scheduling instead, leave `CRON_SCHEDULE` unset; Cronitor cannot monitor IPTVBoss internal scheduling.

```yaml
services:
  iptvboss-xpra:
    image: ghcr.io/groenator/iptvboss-xpra-stable:<version> # The image has support for both ARM and x86 devices.
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
    --name iptvboss-xpra \
    -p 5454:5454 \
    -e PUID=1000 -e PGID=1000 \
    -e TZ=US/Eastern \
    -e CRON_SCHEDULE="0 0 * * *" \
    -e CRONITOR_API_KEY="<your_cronitor_api_key>" \
    -e CRONITOR_SCHEDULE_NAME="My IPTVBoss Job" \
    -v <your-local-volume>:/headless/IPTVBoss \
    ghcr.io/groenator/iptvboss-xpra-stable:latest
```

## Access Xpra and launch IPTVBoss

1. Open `http://your-host-ip:5454` in your browser.
2. IPTVBoss starts when the browser client connects. You can also use Applications -> IPTVBoss if it is not already running.
3. If needed, open Applications -> Terminal for shell access.

## Audio and media playback

The image includes VLC, the native VLC development library, FFmpeg codecs, and a dedicated PulseAudio speaker sink. IPTVBoss stream video and speaker audio can therefore be delivered through the Xpra HTML5 session without mounting the host's `/dev/snd` device. Microphone forwarding is disabled.

Browser autoplay policies can still require a user interaction before audio begins. If a stream is silent, confirm that the Xpra toolbar speaker control and the browser tab are not muted.

## Build locally

```bash
docker build -f Dockerfile.xpra \
    --build-arg LATEST_TAG=<iptvboss-release-tag> \
    -t iptvboss-xpra:stable .
```

See also: [Cronitor Integration](Cronitor-Integration).
