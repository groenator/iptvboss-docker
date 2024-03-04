# IPTVBoss VNC Docker Image

This Docker image provides a VNC server with the IPTVBoss application. It includes the option to configure Cronitor for monitoring.

IPTVBoss is pre-installed via apt in the `/usr/lib/iptvboss` directory. You can customize its configuration and settings.

## Prerequisites

- Docker installed on your machine. See [Docker documentation](https://docs.docker.com/get-docker/) for installation instructions.
- Docker-compose. See [Docker Compose documentation](https://docs.docker.com/compose/install/) for installation instructions.
- A Linux or Mac computer to build the Docker image. I don't use Windows, for Windows I recommend using WSL2.

## Features

- Ubuntu-based VNC server.
- IPTVBoss application pre-installed.
- Automatically configuring the cron job for updating the tasks.
- Cronitor.io integration for monitoring the cron job(optional)

## Building the Docker Image

```bash
docker build -t iptvboss .
```

## Docker Compose (preferred way)

Use Docker Compose to manage the Docker container. An example docker-compose.yml file is provided:

```yaml
version: "2.1"
services:
  iptvboss:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: iptvboss
    environment:
      CRONITOR_API_KEY: "<your_cronitor_api_key>"
    ports:
      - 5901:5901
      - 6901:6901
    volumes:
      - <local_volume>:/headless/IPTVBoss # Replace <local_volume> with the local directory where you want to store the IPTVBoss data. E.g., /home/user/iptvboss
```

Adjust the configuration as needed and run:

```bash
docker-compose up -d
```

Alternatively, you can run the Docker container using the following command:

```bash
docker run -d -p 5901:5901 -p 6901:6901 --name iptvboss iptvboss
```

## Accessing the VNC Server

Connect to the VNC server using your preferred VNC client or any browser by opening below URL.

To connect to the VNC server using a VNC client, use the following address:

`vnc://your-machine-ip:5901`

To connect to the VNC server using a web browser, use the following address.

`http://<your-machine-ip>:6901/password=vncpassword`. Alternatively, if you deploy it locally replace IP with `localhost`.

The default password is `vncpassword`. Replace localhost with your actual server IP address.

## Cron Job

A cron job is set up to perform periodic EPG update tasks. You can modify the cron schedule by editing the iptvboss-cron file.

## Cronitor Integration (Optional)

Prerequisites:

- A Cronitor account. Sign up at [Cronitor.io](https://cronitor.io).
- A Cronitor API key.

To enable Cronitor monitoring, set the build argument while building the image:

```bash
docker build -t iptvboss --build-arg CRONITOR_API_KEY=your_api_key .
```
