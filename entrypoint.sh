#!/bin/bash
set -euo pipefail

cleanup() {
    echo "Caught SIGTERM – cleaning up..."
    exit 0
}
trap cleanup SIGTERM SIGINT

# Expect HOST_UID and HOST_GID as environment variables (or fall back to 1000)
HOST_UID=${HOST_UID:-1000}
HOST_GID=${HOST_GID:-1000}

# Change the uid/gid of the placeholder account
usermod -u "$HOST_UID" zfsbackups
groupmod -g "$HOST_GID" zfsbackups

# Make sure the home directory has the correct ownership
chown -R "$HOST_UID":"$HOST_GID" /data/zfsbackups

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
