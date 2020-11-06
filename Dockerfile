FROM runatlantis/atlantis:latest

RUN apk add unzip make curl
RUN chown atlantis:atlantis /home/atlantis/ -R
# TODO: verify GPG
ARG TERRAGRUNT_VERSION=0.21
ENV DEFAULT_TERRAGRUNT_VERSION=$TERRAGRUNT_VERSION
ARG TERRAFORM_VERSION=0.12
ENV DEFAULT_TERRAFORM_VERSION=$TERRAFORM_VERSION

RUN set -eux \
    && if [ "${TERRAFORM_VERSION}" = "latest" ]; then \
          DEFAULT_TERRAFORM_VERSION="$( curl -sS https://releases.hashicorp.com/terraform/ \
                  | tac | tac \
                  | grep -Eo '/[.0-9]+/' \
                  | grep -Eo '[.0-9]+' \
                  | sort -V \
                  | tail -1 )"; \
    else \
        DEFAULT_TERRAFORM_VERSION="$( curl -sS https://releases.hashicorp.com/terraform/ \
			| tac | tac \
			| grep -Eo "/${TERRAFORM_VERSION}\.[.0-9]+/" \
			| grep -Eo '[.0-9]+' \
			| sort -V \
			| tail -1 )"; \
    fi \
    && rm -rf /usr/local/bin/terraform \
    && ln -s /usr/local/bin/tf/versions/${DEFAULT_TERRAFORM_VERSION}/terraform /usr/local/bin/terraform

RUN set -eux \
    && if [ "${TERRAGRUNT_VERSION}" = "latest" ]; then \
          DEFAULT_TERRAGRUNT_VERSION="$( curl -L -sS https://github.com/gruntwork-io/terragrunt/releases \
                  | tac | tac \
                  | grep -Eo '/v[.0-9]+/' \
                  | grep -Eo '[.0-9]+' \
                  | sort -u \
                  | sort -V \
                  | tail -1 )"; \
    else \
        git clone https://github.com/gruntwork-io/terragrunt /terragrunt; \
        cd /terragrunt; \
        DEFAULT_TERRAGRUNT_VERSION="$( git tag | grep -E "v${TERRAGRUNT_VERSION}\.[.0-9]+" | grep -Eo '[.0-9]+' | sort -u | sort -V | tail -1 )"; \
        cd ..; \
        rm -fr terragrunt; \
    fi \
    # Download the binary and checksum
    && curl -OLSs "https://github.com/gruntwork-io/terragrunt/releases/download/v${DEFAULT_TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
    && curl -OLSs "https://github.com/gruntwork-io/terragrunt/releases/download/v${DEFAULT_TERRAGRUNT_VERSION}/SHA256SUMS" \
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

RUN chown atlantis:atlantis /home/atlantis/ -R
