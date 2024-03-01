# IPTVBoss VNC Docker Image

This Docker image provides a VNC server with the IPTVBoss application. It includes the option to configure Cronitor for monitoring.

## Features

- CentOS-based VNC server.
- IPTVBoss application pre-installed.
- Cron job for periodic tasks.
- Optional Cronitor integration for monitoring.

## Usage

```bash
docker run -d -p 5901:5901 -p 6901:6901 --name iptvboss-vnc iptvboss-vnc
```

### Building the Docker Image

```bash
docker build -t iptvboss-vnc .
```

Adjust the ports and container name as needed.

## Configuration

### IPTVBoss

IPTVBoss is pre-installed in the `/usr/lib/iptvboss` directory. You can customize its configuration and settings.

## Cron Job

A cron job is set up to perform periodic tasks. You can modify the cron schedule by editing the iptvboss-cron file.

## Cronitor Integration (Optional)

Prerequisites:

- A Cronitor account. Sign up at [Cronitor.io](https://cronitor.io).
- A Cronitor API key.

To enable Cronitor monitoring, set the build arguments while building the image:

```bash
docker build -t iptvboss-vnc --build-arg CRONITOR_ENABLE=true --build-arg CRONITOR_API_KEY=your_api_key .
```

Alternatively, edit the `docker-compose.yml` file.

## Docker Compose

You can also use Docker Compose to manage the Docker container. An example docker-compose.yml file is provided:

```yaml
version: "2.1"
services:
  iptvboss-vnc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: iptvboss-vnc
    environment:
      CRONITOR_ENABLE: "true"
      CRONITOR_API_KEY: "<your_cronitor_api_key>"
    ports:
      - 5901:5901
      - 6901:6901
    volumes:
      - <local_volume>:/headless/IPTVBoss
```

Adjust the configuration as needed and run:

```bash
docker-compose up -d
```

## VNC Connection

Connect to the VNC server using your preferred VNC client. The default password is `vncpassword`.

```text
http://localhost:6901/password=vncpassword
```
