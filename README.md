# IPTVBoss Docker Images

This repo builds Docker images for running [IPTVBoss](https://github.com/walrusone/iptvboss-release/releases/latest):

- VNC desktop images (stable + beta)
- Headless XC images (stable + beta)
- Xpra browser-window images (stable + beta)

- IPTVBoss is pre-installed via apt in the `/usr/lib/iptvboss` directory. You can customize its configuration and settings.
- It includes the option to configure Cronitor to monitor the local cron jobs.
- rclone is also installed in the VNC image to allow users to sync their IPTVBoss data to a cloud storage provider.

## Documentation

| Image | Description | Docs |
| --- | --- | --- |
| VNC — Stable | Full XFCE desktop, Firefox/Chromium, VNC + noVNC | [docs/vnc-stable.md](docs/vnc-stable.md) |
| VNC — Beta | Same as above, tracks a beta IPTVBoss release | [docs/vnc-beta.md](docs/vnc-beta.md) |
| Headless — Stable | XC server + cron only, no GUI | [docs/headless-stable.md](docs/headless-stable.md) |
| Headless — Beta | Same as above, tracks a beta IPTVBoss release | [docs/headless-beta.md](docs/headless-beta.md) |
| Xpra — Stable | Browser access to IPTVBoss app windows over Xpra HTML5 | [docs/xpra-stable.md](docs/xpra-stable.md) |
| Xpra — Beta | Same Xpra setup, tracks a beta IPTVBoss release | [docs/xpra-beta.md](docs/xpra-beta.md) |
| Cronitor integration | Optional cron job monitoring, applies to all six images | [docs/cronitor.md](docs/cronitor.md) |

## Xpra image quickstart (Web GUI)

Xpra publishes IPTVBoss app windows directly in the browser.

Why this image exists:

- The older VNC base stack has been harder to maintain because upstream updates have been slow.
- Keeping that stack running required manual Debian repository workarounds during updates.
- Running a full XFCE desktop just to launch IPTVBoss adds extra overhead.
- Xpra gives a lighter browser GUI path focused on IPTVBoss + basic helper apps like Terminal.

Build stable:

```bash
docker build -f Dockerfile.xpra \
  --build-arg LATEST_TAG=$(cat release) \
  -t ghcr.io/groenator/iptvboss-xpra-stable:latest .
```

Build beta:

```bash
docker build -f Dockerfile.xpra \
  --build-arg BETA_TAG=$(cat beta-release) \
  -t ghcr.io/groenator/iptvboss-xpra-beta:latest .
```

Run:

```bash
docker run --rm -p 5454:5454 \
  -e PUID=1000 -e PGID=1000 \
  -e CRON_SCHEDULE="0 0 * * *" \
  -e CRONITOR_API_KEY="<your_cronitor_api_key>" \
  -e CRONITOR_SCHEDULE_NAME="My IPTVBoss Job" \
  -v <your-local-volume>:/config \
  ghcr.io/groenator/iptvboss-xpra-stable:latest
```

Open `http://localhost:5454` in your browser.

In the Xpra top menu, use **Applications** to launch IPTVBoss and Terminal. IPTVBoss is configured to launch on client connect so window placement matches your actual browser display.

Use a terminal in the Xpra session (or `docker exec`) to inspect cron state:

```bash
docker exec -it iptvboss-xpra sh -lc 'crontab -u app -l; ps -ef | grep cron | grep -v grep; tail -n 50 /config/log/cron.log'
```

## If you are unable to connect to your cloud provider, this is likely because of

1. Running the container using root and not using a non-root user

- DO NOT RUN the container using ROOT user, it won't work.

1. The container volumes are not mounted correctly, the volume permissions are incorrect

- Define your own user and set the correct permissions for your volume using your user UID/GID details.

## Security recommendations if running on a VPS

The VNC image exposes a VNC server and noVNC web client with only a simple password, and the headless image exposes the XC server with no authentication at all. If you are running any of these images on a VPS or another host with a public IP, do not leave those ports open to the whole internet.

- Set up a firewall on the VPS (e.g. `ufw`, `iptables`, or your provider's security group/firewall) and block all inbound access by default.
- Only allow access from trusted/known IP addresses if you need direct access to the exposed ports (`5901`, `6901`, `8001`).
- Better yet, don't publish these ports publicly at all. Put the host on a private overlay network such as [Tailscale](https://tailscale.com/) (or WireGuard), close the ports on the public firewall entirely, and connect to the container only through the VPN.
- Change the default VNC password (`VNC_PW`, see [docs/vnc-stable.md](docs/vnc-stable.md)) instead of relying on the default.
- Keep the image and host OS up to date to pick up security patches.

## Prerequisites

- Docker installed on your machine. See [Docker documentation](https://docs.docker.com/get-docker/) for installation instructions.
- Docker-compose. See [Docker Compose documentation](https://docs.docker.com/compose/install/) for installation instructions.
- A Linux or Mac computer to build the Docker image. I don't use Windows, for Windows I recommend using WSL2.
- Cronitor.io account and API key (optional).

## Features

- Debian-based VNC image, Ubuntu-based headless image.
- IPTVBoss application pre-installed.
- XC Server starting on boot only when setting the `XC_SERVER=true` variable, otherwise it won't start.
- Run the container as a non-root user with the desired `PUID` and `PGID` set up.
- Pre-configured VNC server with a default password (VNC images only). Override via environment variables — see [docs/vnc-stable.md](docs/vnc-stable.md).
- Xpra browser-window images for lightweight GUI access without a full desktop — see [docs/xpra-stable.md](docs/xpra-stable.md).
- Automatically configuring the cron job for updating the EPG.
- Cronitor.io integration for monitoring the cron job (optional).
- rclone support to sync IPTVBoss data to a cloud storage provider (VNC image only).
- ARM support for Raspberry Pi and other ARM devices. Use the `ghcr.io/groenator/iptvboss-docker:latest` image.

## Tasks list

- [x] Create a Docker image with IPTVBoss running as a simple cli without GUI and VNC.
- [x] Configure IPTVBoss XC to start on boot.
- [x] Pushing the docker image to an actual docker registry.
- [x] Allow user to configure the cron job with it's own schedule. At the moment the cron is configured to run every 12h.
- [x] Start the container defining your own user.
- [x] Creating a script to configure the cronitor jobs automatically without duplicating the job if is already available in the account.
