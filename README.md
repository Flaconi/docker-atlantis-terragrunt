# Atlantis Docker image with Terragrunt

[![Build Status](https://github.com/Flaconi/docker-atlantis-terragrunt/workflows/Build-Publish/badge.svg)](https://github.com/Flaconi/docker-atlantis-terragrunt/actions?query=workflow%3ABuild-Publish)
[![Dockerhub](https://img.shields.io/badge/dockerhub-atlantis--terragrunt-blue.svg)](https://hub.docker.com/r/flaconi/atlantis-terragrunt)


## About

This Docker image is pulling the atlantis image from runatlantis/atlantis, and additionaly installs Terraform and Terragrunt for further use.
The Dockerfile was adapted from https://github.com/chenrui333/atlantis-terragrunt


## Building

For building you can overwrite your desired versions with the following three Makefile variables:
* `ATLANTIS`
* `TERRAFORM`
* `TERRAGRUNT`
* `TERRAGRUNT_ATLANTIS_CONFIG`
* `SOPS`
* `ONE_PASSWORD_CLI`

e.g.
```
make build
make build TERRAFORM=1.7.2
make build TERRAFORM=1.7.2 TERRAGRUNT=0.55.1
make build TERRAFORM=1.7.2 TERRAGRUNT=0.55.1 ATLANTIS=0.27.1
make build TERRAFORM=1.7.2 TERRAGRUNT=0.55.1 ATLANTIS=0.27.1 SOPS=3.8.1
```

## Available images


[![Docker hub](http://dockeri.co/image/flaconi/atlantis-terragrunt)](https://hub.docker.com/r/flaconi/atlantis-terragrunt)

### Immutable images

Immutable images are created when this git repository is tagged. The Docker image tags are in the following format:
```
flaconi/atlantis-terragrunt:<ATLANTIS_VERSION>-<TERRAFORM_VERSION>-<TERRAGRUNT_VERSION>-<GIT_TAG>
```

### Mutable images

Mutable images are created on `release-*` branches and master merge

```
# On release-* branch
flaconi/atlantis-terragrunt:<ATLANTIS_VERSION>-<TERRAFORM_VERSION>-<TERRAGRUNT_VERSION>-release-<SUFFIX>

# On master
flaconi/atlantis-terragrunt:<ATLANTIS_VERSION>-<TERRAFORM_VERSION>-<TERRAGRUNT_VERSION>
```

## License

[MIT](LICENSE)

Copyright (c) 2024 [Flaconi GmbH](https://github.com/Flaconi)
