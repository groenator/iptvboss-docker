# IPTVBoss VNC Docker Image

## If you are unable to connect to your cloud provider, this is likely because of:
1. Running the container using root and not using a non-root user
  - DO NOT RUN the container using ROOT user, it won't work.
2. The container volumes are not mounted correctly, the volume permissions are incorrect
  - Define your own user and set the correct permissions for your volume using your user UID/GID details.
-----------------------------------------------------------------------------------------------------------------------------------------
- This Docker image provides a VNC server with the [IPTVBoss application](https://github.com/walrusone/iptvboss-release/releases/latest).
- IPTVBoss is pre-installed via apt in the `/usr/lib/iptvboss` directory. You can customize its configuration and settings.
- It includes the option to configure Cronitor to monitor the local cron jobs. View the instructions below to enable Cronitor monitoring.
- rclone is also installed in the container to allow users to sync their IPTVBoss data to a cloud storage provider.

## Prerequisites

- Docker installed on your machine. See [Docker documentation](https://docs.docker.com/get-docker/) for installation instructions.
- Docker-compose. See [Docker Compose documentation](https://docs.docker.com/compose/install/) for installation instructions.
- A Linux or Mac computer to build the Docker image. I don't use Windows, for Windows I recommend using WSL2.
- Cronitor.io account and API key (optional).

## Features

- Debian-based VNC server.
- IPTVBoss application pre-installed.
- XC Server starting on boot only when setting the `XC_SERVER=true` variable, otherwise it won't start.
- Run the container as a non-root user with the desire `PUID` and `PGID` set up.
- Pre-configured VNC server with a default password. User can change the VNC settings by overriding the environment variables, see below for more info.
- Automatically configuring the cron job for updating the EPG.
- Cronitor.io integration for monitoring the cron job(optional)
- rclone support to sync IPTVBoss data to a cloud storage provider.
- ARM support for Raspberry Pi and other ARM devices. Use the `ghcr.io/groenator/iptvboss-docker:latest` image.

## Tasks list

- [ ] Create a Docker image with IPTVBoss running as a simple cli without GUI and VNC.
- [x] Configure IPTVBoss XC to start on boot.
- [x] Pushing the docker image to an actual docker registry.
- [x] Allow user to configure the cron job with it's own schedule. At the moment the cron is configured to run every 12h.
- [x] Start the container defining your own user.
- [x] Creating a script to configure the cronitor jobs automatically without duplicating the job if is already available in the account.

## Docker Compose (preferred way)

**Note:**

- *The volume is mounted to the `/headless/IPTVBoss` directory in the container.*
- *If the volume mounted doesn't have the correct permissions IPTVBoss will NOT start. Before mounting the volume make sure the permissions on the local folder are set correctly.*
- *A cron job is set up to perform periodic EPG update tasks. Change the cron schedule by setting the `CRON_SCHEDULE` environment variable with your own schedule.*
- *To use XC server expose port 8001 and set `XC_SERVER=true` variable. If you don't need it, remove the port and variable. Access the XC server via your browser at `http://<your-machine-ip>:8001`.*

Use Docker Compose to manage the Docker container. An example docker-compose.yml file is provided:

```yaml
services:
  iptvboss:
    image: ghcr.io/groenator/iptvboss-docker:latest # The Image has support for both ARM and x86 devices.
    environment:
      PUID: "1000" # Set the user ID for the container.
      PGID: "1000" # Set the group ID for the container.
      TZ: "US/Eastern" #Set the timezone for the container.
      CRON_SCHEDULE: "0 0 * * *" #Set the cron schedule for the cron job that will update the EPG data.
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
docker run -it -p 6911:6901 -p 8001:8001
-v <your-local-volume>:/headless/IPTVBoss
-e PUID=1000 -e PGID=1000
-e CRON_SCHEDULE="* * * * *"
-e TZ=US/Eastern -e XC_SERVER=true
ghcr.io/groenator/iptvboss-docker:latest
```

Alternatively, you can also set the user and group id using the PUID and PGID environment variables in the docker-compose file as showing above.

Then, run the bellow command:

```bash
docker-compose up -d
```

## Beta Version Available!

**Please note that this is a beta release and may contain bugs.**

A beta version of the IPTVBoss Docker image is available for testing.

It is highly recommended to back up your IPTVBoss data before using the beta version.

To use the beta version, replace the image field from your docker-compose with the `iptvboss-docker-beta` package with the `<version>` tag:

```bash
services:
  iptvboss:
    image: ghcr.io/groenator/iptvboss-docker-beta:<version>  # Use the beta image with tag
    # ... (rest of your docker-compose configuration)
```
Example deploying the beta version using docker cli:

```bash
docker run -it -p 5901:5901 -p 6901:6901 -p 8001:8001 \
    --name iptvboss \
    -e PUID=1000 -e PGID=1000 \
    # ... (other environment variables) \
    -v <your-local-volume>:/headless/IPTVBoss \
    ghcr.io/groenator/iptvboss-docker-beta:<version>  # Use the beta image with tag
```

## Accessing the VNC Server

Connect to the VNC server using your preferred VNC client or any browser by opening below URL.

To connect to the VNC server using a VNC client, use the following address:

`vnc://your-machine-ip:5901`

To connect to the VNC server using a web browser, use the following address.

`http://<host-ip>:6901/?password=vncpassword`.

If you deploy it outside of your locally replace IP with `localhost`.

The default password is `vncpassword`. Replace localhost with your actual server IP address.

## Override VNC environment variables

The following VNC environment variables can be overwritten at the docker run phase to customize your desktop environment inside the container:

```bash
VNC_COL_DEPTH, default: 24
VNC_RESOLUTION, default: 1280x1024
VNC_PW, default: my-pw
VNC_PASSWORDLESS, default: <not set>
```

## Cronitor Integration (Optional)

Prerequisites:

- A Cronitor account. Sign up at [Cronitor.io](https://cronitor.io).
- A Cronitor API key.

To enable Cronitor monitoring, set the `CRONITOR_API_KEY` environment variable to your Cronitor API key. Set the `CRONITOR_SCHEDULE_NAME` environment variable to a custom name for your Cronitor job.

Run it using docker-compose:

```yaml
services:
  iptvboss:
    image: ghcr.io/groenator/iptvboss-docker:latest # The Image has support for both ARM and x86 devices.
    environment:
      PUID: "1000" # Set the user ID for the container.
      PGID: "1000" # Set the group ID for the container.
      CRON_SCHEDULE: "0 0 * * *" # Set the cron schedule for the cron job that will update the EPG data.
      CRONITOR_API_KEY: "<your_cronitor_api_key>"
      CRONITOR_SCHEDULE_NAME: "My Custom Schedule" # Set a name for your Cronitor.io Job
      XC_SERVER: "true" # Set to true to start the XC server on boot. By default the XCSERVER is set to false.
      TZ: "US/Eastern" #Set the timezone for the container.
    ports:
    - 8001:8001 # Used by XC Server
    - 5901:5901 # Used by the VNC Server to connect to the container using the VNC client.
    - 6901:6901 # Used by the VNC Server to connect to the container using a web browser.
    volumes:
    # Replace <local_volume> with the local directory where you want to store the IPTVBoss data. E.g., /home/user/iptvboss.
    # Based on the PUID and PGID environment variables the folder permissions are set at runtime.
    - <local_volume>:/headless/IPTVBoss
```

Run the following command to start the container:

```bash
docker-compose up -d
```

Or using the following command:

```bash
# Remove the double quotes around CRONITOR_API_KEY value and replace <your_cronitor_api_key> with your actual Cronitor API key.
docker run -it -p 5901:5901 -p 6901:6901 -p 8001:8001
--name iptvboss
-e PUID=1000 -e PGID=1000
-e CRONITOR_API_KEY="<your_cronitor_api_key>"
-e CRONITOR_SCHEDULE_NAME=MyJob
-e CRON_SCHEDULE="* * * * *"
-e XC_SERVER=true
-v <your-local-volume>:/headless/IPTVBoss
ghcr.io/groenator/iptvboss-docker:latest
```
