# IPTVBoss Xpra - Stable

The Xpra stable image runs IPTVBoss in a browser using Xpra HTML5 windows (not a full remote desktop).

- Image: ghcr.io/groenator/iptvboss-xpra-stable:latest
- Port: 5454 (Xpra WebSocket / HTML5 client)
- Data volume: /config

## Why this image exists

- The older VNC base stack has been harder to maintain because upstream updates have been slow.
- Keeping that path buildable required manual Debian repository workarounds during updates.
- Running a full XFCE desktop just to use IPTVBoss is heavier than needed for many users.
- This Xpra image keeps GUI access simple and lightweight: browser window + IPTVBoss + helper apps.

## Docker Compose

```yaml
services:
  iptvboss-xpra:
    image: ghcr.io/groenator/iptvboss-xpra-stable:latest
    environment:
      PUID: "1000"
      PGID: "1000"
      TZ: "US/Eastern"
      CRON_SCHEDULE: "0 0 * * *"
      CRONITOR_API_KEY: "<your_cronitor_api_key>"
      CRONITOR_SCHEDULE_NAME: "My IPTVBoss Job"
    ports:
      - 5454:5454
    volumes:
      - <local_volume>:/config
```

Start:

```bash
docker-compose up -d
```

## Docker CLI

```bash
docker run -it --rm \
    --name iptvboss-xpra \
    -p 5454:5454 \
    -e PUID=1000 -e PGID=1000 \
    -e TZ=US/Eastern \
    -e CRON_SCHEDULE="0 0 * * *" \
    -e CRONITOR_API_KEY="<your_cronitor_api_key>" \
    -e CRONITOR_SCHEDULE_NAME="My IPTVBoss Job" \
    -v <your-local-volume>:/config \
    ghcr.io/groenator/iptvboss-xpra-stable:latest
```

Open `http://your-host-ip:5454` in your browser.

In the Xpra top menu, use Applications to launch IPTVBoss and Terminal.

## Build locally

```bash
docker build -f Dockerfile.xpra \
    --build-arg LATEST_TAG=<iptvboss-release-tag> \
    -t iptvboss-xpra:stable .
```

See also: [Cronitor integration](cronitor.md).
