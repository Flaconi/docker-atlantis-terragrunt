#!/usr/bin/dumb-init /bin/sh
set -eo pipefail

# the script is being executed by the root user
ATLANTIS_HOME=/home/atlantis

if [[ ! -z "$GITHUB_USER_SSH_KEY" ]] ; then
  mkdir -p "$ATLANTIS_HOME/.ssh"

  if [ ! -f "$ATLANTIS_HOME/.ssh/id_rsa" ]; then
    echo "${GITHUB_USER_SSH_KEY}" | base64 -d | gunzip > "${ATLANTIS_HOME}/.ssh/id_rsa"
    chmod 600 "$ATLANTIS_HOME/.ssh/id_rsa"
    ssh-keyscan github.com >> "$ATLANTIS_HOME/.ssh/known_hosts"
    chown atlantis:atlantis "$ATLANTIS_HOME/.ssh/id_rsa"
    chown atlantis:atlantis "$ATLANTIS_HOME/.ssh/known_hosts"
  fi
fi
