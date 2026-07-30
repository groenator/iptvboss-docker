# IPTVBoss Headless — Beta

**Please note that this is a beta release and may contain bugs.** It is highly recommended to back up your IPTVBoss data before using the beta version.

`Beta` here refers to the IPTVBoss app release channel. This image tracks official IPTVBoss beta releases (from the `beta-release` tag/file), not a separate "beta container" codebase.

Builds the same [`Dockerfile.headless`](../Dockerfile.headless) as the [stable headless image](headless-stable.md), but pointed at a beta release tag via the `BETA_TAG` build argument instead of `LATEST_TAG`.

- Image: `ghcr.io/groenator/iptvboss-docker-headless-beta:<version>`
- Ports: `8001` (XC server) only
- Data volume: `/headless/IPTVBoss`

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
    image: ghcr.io/groenator/iptvboss-docker-headless-beta:<version> # The image has support for both ARM and x86 devices.
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
    --name iptvboss-headless-beta \
    -e PUID=1000 -e PGID=1000 \
    -e CRON_SCHEDULE="0 0 * * *" \
    -e CRONITOR_API_KEY="<your_cronitor_api_key>" \
    -e CRONITOR_SCHEDULE_NAME="My IPTVBoss Job" \
    -e TZ=US/Eastern \
    -v <your-local-volume>:/headless/IPTVBoss \
  ghcr.io/groenator/iptvboss-docker-headless-beta:latest
```

Everything else (environment variables, volume/permission requirements, Cronitor integration) is identical to the [stable headless image](headless-stable.md).
