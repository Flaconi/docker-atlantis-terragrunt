#!/bin/dumb-init /bin/sh
set -xev
create_github_user_ssh_key.sh
mount
chown atlantis.atlantis /mnt/efs -R
ls -la /mnt
whoami
set -- docker-entrypoint-original.sh "$@"
exec "$@"
