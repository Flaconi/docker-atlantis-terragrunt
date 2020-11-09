#!/bin/dumb-init /bin/sh
set -xev
create_github_user_ssh_key.sh
chown atlantis.atlantis /mnt/efs -R
set -- docker-entrypoint-original.sh "$@"
exec "$@"
