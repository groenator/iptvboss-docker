
# Use the official CentOS base image
FROM consol/rocky-xfce-vnc

# Set locale to avoid warnings
ENV LC_ALL=C.UTF-8

# Switch to root temporarily to perform system updates
USER 0

# Install necessary dependencies
RUN yum install -y wget cronie vlc \
    && yum update -y \
    && yum clean all

# Create a new user with home directory set to /headless
RUN useradd -m -d /headless -s /bin/bash iptvboss

# Set the working directory
WORKDIR /headless

# Copy the cron file to the cron.d directory
COPY iptvboss-cron /var/spool/crontab/iptvboss/iptvboss-cron

# Give execution rights on the cron job
RUN chmod 0644 /var/spool/crontab/iptvboss/iptvboss-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Download and extract iptvboss tar
RUN wget "https://github.com/walrusone/iptvboss-release/releases/latest/download/iptvboss-3.4.160.0-linux-amd64.tar.gz" && \
    tar -xzvf iptvboss-3.4.160.0-linux-amd64.tar.gz && \
    cp iptvboss-3.4.160.0/share/applications/io.github.walrusone.iptvboss-release.desktop /headless/Desktop/iptvboss-release.desktop && \
    sed -i 's/Icon=iptvboss/Icon=\/usr\/lib\/iptvboss\/share\/icons\/hicolor\/128x128\/apps\/iptvboss.png/' /headless/Desktop/iptvboss-release.desktop && \
    chmod 777 /headless/Desktop/iptvboss-release.desktop && \
    mv iptvboss-3.4.160.0 /usr/lib/iptvboss && \
    rm -f iptvboss-3.4.160.0-linux-amd64.tar.gz

# Expose VNC port
EXPOSE 5901
EXPOSE 6901

# Switch back to the non-root user
USER 1000
ENV PATH="/usr/lib/iptvboss/bin:${PATH}"

# Apply cron job
RUN crontab /var/spool/crontab/iptvboss/iptvboss-cron