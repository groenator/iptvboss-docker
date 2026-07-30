# IPTVBoss VNC — Stable

Full desktop VNC image built from [`Dockerfile`](../Dockerfile), based on `consol/debian-xfce-vnc`. Gives you a full XFCE desktop with the IPTVBoss application, Firefox and Chromium pre-installed, reachable via any VNC client or a browser (noVNC).

`Stable` here refers to the IPTVBoss app release channel. This image tracks official non-beta IPTVBoss releases (from the `release` tag/file), not a separate "stable container" codebase.

- Image: `ghcr.io/groenator/iptvboss-docker:latest`
- Ports: `5901` (VNC client), `6901` (noVNC web client), `8001` (XC server, optional)
- Data volume: `/headless/IPTVBoss`

## Docker Compose (preferred way)

**Note:**

- *The volume is mounted to the `/headless/IPTVBoss` directory in the container.*
- *If the volume mounted doesn't have the correct permissions IPTVBoss will NOT start. Before mounting the volume make sure the permissions on the local folder are set correctly.*
- *Scheduling mode 1: use container-managed cron by setting `CRON_SCHEDULE`.*
- *Scheduling mode 2: use IPTVBoss internal scheduling by leaving `CRON_SCHEDULE` unset.*
- *Cronitor only monitors scheduling mode 1 (container cron), not IPTVBoss internal scheduling.*
- *`CRONITOR_API_KEY` and `CRONITOR_SCHEDULE_NAME` are optional and only needed if you want Cronitor monitoring of container-managed cron.*
- *To use XC server expose port 8001 and set `XC_SERVER=true` variable. If you don't need it, remove the port and variable. Access the XC server via your browser at `http://<your-machine-ip>:8001`.*

```yaml
services:
  iptvboss:
    image: ghcr.io/groenator/iptvboss-docker:<version> # The Image has support for both ARM and x86 devices.
    environment:
      PUID: "1000" # Set the user ID for the container.
      PGID: "1000" # Set the group ID for the container.
      TZ: "US/Eastern" # Set the timezone for the container.
      CRON_SCHEDULE: "0 0 * * *" # Optional: set only when using container-managed cron scheduling.
      CRONITOR_API_KEY: "<your_cronitor_api_key>" # Optional: required only for Cronitor monitoring.
      CRONITOR_SCHEDULE_NAME: "My IPTVBoss Job" # Optional: custom Cronitor monitor name.
      XC_SERVER: "true" # Set to true to start the XC server on boot. By default the XCSERVER is set to false.
    ports:
      - 8001:8001 # Used by XC Server
      - 5901:5901 # Used by the VNC Server to connect to the container using the VNC client.
      - 6901:6901 # Used by the VNC Server to connect to the container using a web browser.
    volumes:
    # Replace <local_volume> with the local directory where you want to store the IPTVBoss data. E.g., /home/user/iptvboss.
    # Based on the PUID and PGID environment variables the folder permissions are set at runtime.
    - <local_volume>:/headless/IPTVBoss
```

Adjust the configuration as needed and run:

```bash
docker-compose up -d
```

## Change User of running VNC Container

The user can define their own PUID and PGID to run the container as a non-root user. This is useful for security reasons. The user can also set the user and group ID of the host system to run the container as the same user and group of the host system.

```bash
docker run -it -p 6911:6901 -p 8001:8001 \
    -v <your-local-volume>:/headless/IPTVBoss \
    -e PUID=1000 -e PGID=1000 \
    -e CRON_SCHEDULE="* * * * *" \
    -e CRONITOR_API_KEY="<your_cronitor_api_key>" \
    -e CRONITOR_SCHEDULE_NAME="My IPTVBoss Job" \
    -e TZ=US/Eastern -e XC_SERVER=true \
    ghcr.io/groenator/iptvboss-docker:latest
```

Alternatively, set `PUID`/`PGID` in the docker-compose file as shown above, then run:

```bash
docker-compose up -d
```

## Accessing the VNC Server

Connect to the VNC server using your preferred VNC client or any browser by opening below URL.

To connect to the VNC server using a VNC client, use the following address:

`vnc://your-machine-ip:5901`

To connect to the VNC server using a web browser, use the following address.

`http://<host-ip>:6901/?password=vncpassword`.

If you deploy it outside of your locally replace IP with `localhost`.

The default password is `vncpassword`. Replace localhost with your actual server IP address.

## Full noVNC client and browser clipboard

For browser access, the full noVNC client is recommended:

```text
http://<host-ip>:6901/vnc.html?autoconnect=true&password=vncpassword&resize=scale
```

The full noVNC client provides the browser toolbar and clipboard controls, which makes copy/paste work better from the browser.

The lite noVNC client is still available:

```text
http://<host-ip>:6901/?password=vncpassword
```

## Override VNC environment variables

The following VNC environment variables can be overwritten at the docker run phase to customize your desktop environment inside the container:

```bash
VNC_COL_DEPTH, default: 24
VNC_RESOLUTION, default: 1280x1024
VNC_PW, default: my-pw
VNC_PASSWORDLESS, default: <not set>
```

## Dropbox authorization links

If Dropbox authorization links do not open, make sure the desktop default browser is set to Mozilla Firefox.

Inside the VNC desktop:

```text
Applications → Settings → Default Applications → Internet → Web Browser → Mozilla Firefox
```

The container now sets Mozilla Firefox as the default XFCE/XDG web browser when no existing user preference is found.

## Desktop launcher "Untrusted application launcher" prompt

The first time you double-click a Desktop icon (IPTVBoss, Firefox, Chromium) after a fresh volume, XFCE will show an "Untrusted application launcher" dialog. Click **Mark As Secure And Launch** once per icon — the container backs up that trust decision to your persistent volume (`/headless/IPTVBoss/gvfs-metadata-home`) every few seconds, so it survives container restarts and redeploys and you won't need to click it again.

See also: [Cronitor integration](cronitor.md).
