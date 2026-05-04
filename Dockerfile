# Dockerhub lists the latest tag as to the latest LTS release
FROM ubuntu:noble

RUN apt-get update && apt-get install -y \
  build-essential \
  nano \
  less \
  zfsutils-linux \
  mbuffer \
  openssh-server \
  openssh-client \
  cron \
  supervisor \
  tini \
  telnet \
  iproute2 \
  net-tools \
  iputils-ping \
  rsyslog \
  bmon \
  wget \
  && rm -rf /var/lib/apt/lists/*

#  sanoid \

RUN cd /tmp/ && \
  wget https://github.com/jimsalterjrs/sanoid/archive/refs/tags/v2.3.0.tar.gz && \
  tar -xf v2.3.0.tar.gz && \
  cd /tmp/sanoid-2.3.0 && \
  ln -s packages/debian . && \
  dpkg-buildpackage -uc -us && \
  apt install ../sanoid_*_all.deb

# remove unnecessary installed cron files because this isn't a normal system
RUN rm -f /etc/cron.d/zfsutils-linux && \
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
COPY ./supervisord.conf /etc/supervisor/supervisord.conf
COPY ./entrypoint.sh /usr/local/sbin/entrypoint.sh
RUN chmod 555 /usr/local/sbin/entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
