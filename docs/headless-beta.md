# IPTVBoss Headless — Beta

**Please note that this is a beta release and may contain bugs.** It is highly recommended to back up your IPTVBoss data before using the beta version.

Builds the same [`Dockerfile.headless`](../Dockerfile.headless) as the [stable headless image](headless-stable.md), but pointed at a beta release tag via the `BETA_TAG` build argument instead of `LATEST_TAG`.

- Built locally from `Dockerfile.headless` (no pre-built registry image)
- Ports: `8001` (XC server) only

## Build the image

```bash
docker build -f Dockerfile.headless \
    --build-arg BETA_TAG=<iptvboss-beta-tag> \
    -t iptvboss-headless-beta .
```

## Docker Compose

```yaml
services:
  iptvboss-headless-beta:
    build:
      context: .
      dockerfile: Dockerfile.headless
      args:
        BETA_TAG: <iptvboss-beta-tag>
    environment:
      PUID: "1000"
      PGID: "1000"
      TZ: "US/Eastern"
      CRON_SCHEDULE: "0 0 * * *"
    ports:
      - 8001:8001
    volumes:
      - <local_volume>:/headless/IPTVBoss
```

```bash
docker-compose up -d
```

## Docker CLI

```bash
docker run -it -p 8001:8001 \
    --name iptvboss-headless-beta \
    -e PUID=1000 -e PGID=1000 \
    -e CRON_SCHEDULE="0 0 * * *" \
    -e TZ=US/Eastern \
    -v <your-local-volume>:/headless/IPTVBoss \
    iptvboss-headless-beta
```

Everything else (environment variables, volume/permission requirements, Cronitor integration) is identical to the [stable headless image](headless-stable.md).
