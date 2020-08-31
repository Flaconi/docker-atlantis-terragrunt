FROM runatlantis/atlantis:latest

RUN apk add unzip make curl

# TODO: verify GPG
ARG TERRAGRUNT_VERSION='0.21.7'
ARG DEFAULT_TERRAFORM_VERSION=0.12.29
ENV DEFAULT_TERRAFORM_VERSION=$DEFAULT_TERRAFORM_VERSION

RUN  \
  rm -rf /usr/local/bin/terraform \
  && ln -s /usr/local/bin/tf/versions/${DEFAULT_TERRAFORM_VERSION}/terraform /usr/local/bin/terraform

RUN \
# Download the binary and checksum
 curl -OLSs "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
 && curl -OLSs "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/SHA256SUMS" \
# Verify the SHASUM matches the binary.
 && grep terragrunt_linux_amd64 SHA256SUMS > terragrunt_linux_amd64_SHA256SUMS \
 && sha256sum -c terragrunt_linux_amd64_SHA256SUMS \
 && chmod a+x terragrunt_linux_amd64 \
 && mv terragrunt_linux_amd64 /usr/local/bin/terragrunt \
# Clean up
 && rm -rf "SHA256SUMS" \
   "terragrunt_linux_amd64_SHA256SUMS"

RUN mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-original.sh
# the new docker-entrypoint.sh will do some work and then call the original entry point
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ADD create_github_user_ssh_key.sh /usr/local/bin/create_github_user_ssh_key.sh
