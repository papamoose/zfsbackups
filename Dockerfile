# Dockerhub lists the latest tag as to the latest LTS release
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
  build-essential \
  nano \
  less \
  zfsutils-linux \
  sanoid \
  openssh-server \
  openssh-client \
  cron \
  supervisor \
  tini \
  telnet \
  iproute2 \
  net-tools \
  iputils-ping \
  && rm -rf /var/lib/apt/lists/*

# remove unnecessary installed cron files because this isn't a normal system
rm -f /etc/cron.d/zfsutils-linux
rm -f /etc/cron.d/e2scrub_all
# Maybe we do want sanoid for snapshots
#rm -f /etc/cron.d/sanoid

# Users
RUN userdel ubuntu
RUN useradd -d /data/zfsbackups -m -s /bin/bash zfsbackups \
    && mkdir -p /data/zfsbackups/.ssh \
    && chown -R zfsbackups /data/zfsbackups/.ssh \
    && chmod 700 /data/zfsbackups/.ssh

# SSH
RUN mkdir -p /var/run/sshd

# Customize sshd slightly
RUN sed -i \
      -e 's/#PasswordAuthentication yes/PasswordAuthentication no/' \
      -e 's/X11Forwarding yes/X11Forwarding no/' \
      /etc/ssh/sshd_config

# supervisord
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./entrypoint.sh /usr/local/sbin/entrypoint.sh
RUN chmod 555 /usr/local/sbin/entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
