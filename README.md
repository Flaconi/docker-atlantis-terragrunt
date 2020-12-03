[![Build Status](https://github.com/Flaconi/docker-atlantis-terragrunt/workflows/Build-Publish/badge.svg)](https://github.com/Flaconi/docker-atlantis-terragrunt)
[![Dockerhub](https://img.shields.io/badge/dockerhub-python-blue.svg)](https://hub.docker.com/r/flaconi/atlantis-terragrunt)

# Docker image for Atlantis with Terragrunt implementation

## About
This Docker image is pulling the latest atlantis image from runatlantis/atlantis, and additionaly downloads Terragrunt for further use.
The Dockerfile was adapted from https://github.com/chenrui333/atlantis-terragrunt

## Building

The Atlantis version is set to latest, the Terragrunt version is set in the Dockerfile.

## Private SSH Key

This Docker entrypoint will look for env var GITHUB_USER_KEY, in case it exists, it will do the following to set a private key on the atlantis docker task.
```
echo "${GITHUB_USER_SSH_KEY}" | base64 -d | gunzip > "${HOME}/.ssh/id_rsa"
```

## License

[MIT](LICENSE)

Copyright (c) 2019 [Flaconi GmbH](https://github.com/Flaconi)
