#!/bin/dumb-init /bin/sh
set -xev
create_github_user_ssh_key.sh
set -- docker-entrypoint-original.sh "$@"
exec "$@"
mount
