# IPTVBoss VNC Docker Image

This Docker image provides a VNC server with the IPTVBoss application.
IPTVBoss is pre-installed via apt in the `/usr/lib/iptvboss` directory. You can customize its configuration and settings.
It includes the option to configure Cronitor to monitor the local cron jobs. View the instructions below to enable Cronitor monitoring.

## Prerequisites

- Docker installed on your machine. See [Docker documentation](https://docs.docker.com/get-docker/) for installation instructions.
- Docker-compose. See [Docker Compose documentation](https://docs.docker.com/compose/install/) for installation instructions.
- A Linux or Mac computer to build the Docker image. I don't use Windows, for Windows I recommend using WSL2.
- Cronitor.io account and API key (optional).

## Features

- Debian-based VNC server.
- IPTVBoss application pre-installed.
- Run the container as a non-root user and you can also change the user and group ID of the container.
- Pre-configured VNC server with a default password. User can change the VNC settings by overriding the environment variables.
- Automatically configuring the cron job for updating the EPG.
- Cronitor.io integration for monitoring the cron job(optional)

## Tasks list

- [ ] Configure IPTVBoss XC to start on boot.
- [ ] Allow users to use audio within the container.
- [x] Pushing the docker image to an actual docker registry.
- [x] Allow user to configure the cron job with it's own schedule. At the moment the cron is configured to run every 12h.
- [x] Start the container defining your own user.
- [x] Creating a script to configure the cronitor jobs automatically without duplicating the job if is already available in the account.

## Docker Compose (preferred way)

**Note:**

- *The volume is mounted to the `/headless/IPTVBoss` directory in the container.If the volume mounted doesn't have the correct permissions IPTVBoss will NOT start. Before mounting the volume make sure the permissions on the local folder are set correctly.*
- *A cron job is set up to perform periodic EPG update tasks. Change the cron schedule by setting the CRON_SCHEDULE environment variable with your own schedule.*

Use Docker Compose to manage the Docker container. An example docker-compose.yml file is provided:

```yaml
version: "2.1"
services:
  iptvboss:
    image: ghcr.io/groenator/iptvboss-docker:latest
    environment:
      TZ: "US/Eastern" #Set the timezone for the container.
      CRON_SCHEDULE: "0 0 * * *" #Set the cron schedule for the cron job that will update the EPG data.
    ports:
      - 5901:5901
      - 6901:6901
    volumes:
    # Replace <local_volume> with the local directory where you want to store the IPTVBoss data. E.g., /home/user/iptvboss. Make sure the local folder has the correct permissions, otherwise IPTVBoss will not start.
      - <local_volume>:/headless/IPTVBoss
```

Adjust the configuration as needed and run:

```bash
docker-compose up -d
```

## Change User of running VNC Container

Per default, all container processes will be executed with user id 1000. You can change the user id as follows:

- Using root (user id 0)

Add the --user flag to your docker run command:

`docker run -it -p 6911:6901 --user $(0):$(0) -v <your-local-volume>:/headless/IPTVBoss -e CRON_SCHEDULE="* * * * *" -e TZ=US/Eastern ghcr.io/groenator/iptvboss-docker:latest`

- Using user and group id of host system

Add the --user flag to your docker run command:

`docker run -it -p 6911:6901 --user $(<your-ID>):$(<your-ID>) -v <your-local-volume>:/headless/IPTVBoss -e CRON_SCHEDULE="* * * * *" -e TZ=US/Eastern ghcr.io/groenator/iptvboss-docker:latest`

Alternatively, you can also set the user and group id in the docker-compose file:

```yaml
version: "2.1"
services:
  iptvboss:
    image: ghcr.io/groenator/iptvboss-docker:latest
    user: "1000:1000" # Set the user and group ID for the container.
    environment:
      TZ: "US/Eastern" #Set the timezone for the container.
      CRON_SCHEDULE: "0 0 * * *" #Set the cron schedule for the cron job that will update the EPG data.
    ports:
      - 5901:5901
      - 6901:6901
    volumes:
    # Replace <local_volume> with the local directory where you want to store the IPTVBoss data. E.g., /home/user/iptvboss. Make sure the local folder has the correct permissions, otherwise IPTVBoss will not start.
      - <local_volume>:/headless/IPTVBoss
```

Then, run the bellow command:

```bash
docker-compose up -d
```

## Accessing the VNC Server

Connect to the VNC server using your preferred VNC client or any browser by opening below URL.

To connect to the VNC server using a VNC client, use the following address:

`vnc://your-machine-ip:5901`

To connect to the VNC server using a web browser, use the following address.

`http://<your-machine-ip>:6901/password=vncpassword`.

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

To enable Cronitor monitoring, set the CRONITOR_API_KEY environment variable to your Cronitor API key. Set the CRONITOR_SCHEDULE_NAME environment variable to a custom name for your Cronitor job. Run it using docker-compose:

```yaml
version: "2.1"
services:
  iptvboss:
    user: "1000:1000" # Set the user and group ID for the container.
    image: ghcr.io/groenator/iptvboss-docker:latest
    environment:
      CRON_SCHEDULE: "0 0 * * *" #Set the cron schedule for the cron job that will update the EPG data.
      CRONITOR_API_KEY: "<your_cronitor_api_key>"
      CRONITOR_SCHEDULE_NAME: "My Custom Schedule" # Set a name for your Cronitor.io Job
      TZ: "US/Eastern" #Set the timezone for the container.
    ports:
      - 5901:5901
      - 6901:6901
    volumes:
    # Replace <local_volume> with the local directory where you want to store the IPTVBoss data. E.g., /home/user/iptvboss.
    # Make sure the local folder has the correct permissions, otherwise IPTVBoss will not start.
      - <local_volume>:/headless/IPTVBoss
```

Run the following command to start the container:

```bash
docker-compose up -d
```

Or using the following command:

```bash
# Remove the double quotes around CRONITOR_API_KEY value and replace <your_cronitor_api_key> with your actual Cronitor API key.
docker run -d -p 5901:5901 -p 6901:6901 --name iptvboss --user $(<your-ID>):$(<your-ID>) -v <your-local-volume>:/headless/IPTVBoss -e CRONITOR_API_KEY="<your_cronitor_api_key>" -e CRONITOR_SCHEDULE_NAME=MyJob -e CRON_SCHEDULE="* * * * *" iptvboss
```

## Building the Docker Image (not necessary)

GitHub Actions is building the image automatically and push it to the GitHub Container Registry. However, if you choose to modify the Dockerfile with your own settings, then you can also build the image manually using the following command:

```bash
docker build -t iptvboss .
```

You can run the Docker container using the following command:

```bash
docker run -d -p 5901:5901 -p 6901:6901 --user $(<your-ID>):$(<your-ID>) -v <your-local-volume>:/headless/IPTVBoss -e CRON_SCHEDULE="* * * * *" --name iptvboss iptvboss
```
