# IPTVBoss Xpra - Beta

Please note this is a beta image and may contain bugs. Back up your IPTVBoss data before using it.

This image uses the same Xpra setup as [Xpra stable](xpra-stable.md), but tracks the IPTVBoss beta release.

## Why this image exists

- The older VNC base stack has been harder to maintain because upstream updates have been slow.
- Keeping that path buildable required manual Debian repository workarounds during updates.
- Running a full XFCE desktop just to use IPTVBoss is heavier than needed for many users.
- This Xpra image keeps GUI access simple and lightweight: browser window + IPTVBoss + helper apps.

- Image: ghcr.io/groenator/iptvboss-xpra-beta:version-tag
- Port: 5454
- Data volume: /config

## Docker Compose

Cronitor variables are optional. Include them only if you want Cronitor monitoring.
Cronitor is used to monitor cron job runs and alert on failures. To enable it, create an account at [Cronitor.io](https://cronitor.io) and use your API key.

```yaml
services:
  iptvboss-xpra-beta:
    image: ghcr.io/groenator/iptvboss-xpra-beta:version-tag
    environment:
      PUID: "1000"
      PGID: "1000"
      TZ: "US/Eastern"
      CRON_SCHEDULE: "0 0 * * *"
      # Optional: only set these if you use Cronitor monitoring.
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
    -v <your-local-volume>:/config \
    ghcr.io/groenator/iptvboss-xpra-beta:version-tag
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
