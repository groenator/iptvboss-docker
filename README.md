# IPTVBoss Docker Images

This repo builds Docker images for running [IPTVBoss](https://github.com/walrusone/iptvboss-release/releases/latest):

- VNC desktop images (stable + beta)
- Headless XC images (stable + beta)
- Xpra browser-window images (stable + beta)

IPTVBoss is pre-installed via apt in the `/usr/lib/iptvboss` directory. rclone is included in the VNC, Headless, and Xpra images to sync IPTVBoss data to a cloud storage provider, and Cronitor can optionally monitor the container-managed cron job.

## Prerequisites

- Docker installed on your machine. See [Docker documentation](https://docs.docker.com/get-docker/) for installation instructions.
- Docker-compose. See [Docker Compose documentation](https://docs.docker.com/compose/install/) for installation instructions.
- A Linux or Mac computer to build the Docker image. I don't use Windows, for Windows I recommend using WSL2.
- Cronitor.io account and API key (optional) to monitor your cron jobs.

## Documentation

Full feature list, per-image setup/build/run instructions, connection troubleshooting, and VPS security guidance live on the **[project wiki](https://github.com/groenator/iptvboss-docker/wiki)** — start at the [Home](https://github.com/groenator/iptvboss-docker/wiki/Home) page.

| Image | Description | Docs |
| --- | --- | --- |
| VNC — Stable | Full XFCE desktop, Firefox/Chromium, VNC + noVNC | [VNC Stable](https://github.com/groenator/iptvboss-docker/wiki/VNC-Stable) |
| VNC — Beta | Same as above, tracks a beta IPTVBoss release | [VNC Beta](https://github.com/groenator/iptvboss-docker/wiki/VNC-Beta) |
| Headless — Stable | XC server + cron only, no GUI | [Headless Stable](https://github.com/groenator/iptvboss-docker/wiki/Headless-Stable) |
| Headless — Beta | Same as above, tracks a beta IPTVBoss release | [Headless Beta](https://github.com/groenator/iptvboss-docker/wiki/Headless-Beta) |
| Xpra — Stable | Browser access to IPTVBoss app windows over Xpra HTML5 | [Xpra Stable](https://github.com/groenator/iptvboss-docker/wiki/Xpra-Stable) |
| Xpra — Beta | Same Xpra setup, tracks a beta IPTVBoss release | [Xpra Beta](https://github.com/groenator/iptvboss-docker/wiki/Xpra-Beta) |
| Cronitor integration | Optional cron job monitoring, applies to all six images | [Cronitor Integration](https://github.com/groenator/iptvboss-docker/wiki/Cronitor-Integration) |
| Upcoming release | User announcement, upgrade guidance, and developer notes | [RELEASE_NOTES.md](RELEASE_NOTES.md) |

## Tasks list

- [x] Create a Docker image with IPTVBoss running as a simple cli without GUI and VNC.
- [x] Configure IPTVBoss XC to start on boot.
- [x] Pushing the docker image to an actual docker registry.
- [x] Allow user to configure the cron job with it's own schedule. At the moment the cron is configured to run every 12h.
- [x] Start the container defining your own user.
- [x] Creating a script to configure the cronitor jobs automatically without duplicating the job if is already available in the account.
