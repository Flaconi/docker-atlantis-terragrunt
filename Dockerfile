FROM runatlantis/atlantis:latest

RUN apk add unzip make curl

# TODO: verify GPG
ARG TERRAGRUNT_VERSION=0.21.7
ENV TERRAGRUNT_VERSION=$TERRAGRUNT_VERSION
ARG DEFAULT_TERRAFORM_VERSION=0.12.29
ENV DEFAULT_TERRAFORM_VERSION=$DEFAULT_TERRAFORM_VERSION

RUN set -eux \
    && if [ "${DEFAULT_TERRAFORM_VERSION}" = "latest" ]; then \
          VERSION="$( curl -sS https://releases.hashicorp.com/terraform/ \
                  | tac | tac \
                  | grep -Eo '/[.0-9]+/' \
                  | grep -Eo '[.0-9]+' \
                  | sort -V \
                  | tail -1 )"; \
    else \
        VERSION=$DEFAULT_TERRAFORM_VERSION; \
    fi \
    # else \
    #     VERSION=${DEFAULT_TERRAFORM_VERSION} \
    # fi \
    && rm -rf /usr/local/bin/terraform \
    && ln -s /usr/local/bin/tf/versions/${VERSION}/terraform /usr/local/bin/terraform

RUN set -eux \
    && if [ "${TERRAGRUNT_VERSION}" = "latest" ]; then \
            VERSION="$( curl -L -sS https://github.com/gruntwork-io/terragrunt/releases \
                    | tac | tac \
                    | grep -Eo '/v[.0-9]+/' \
                    | grep -Eo '[.0-9]+' \
                    | sort -u \
                    | sort -V \
                    | tail -1 )"; \
    else \
        VERSION=$TERRAGRUNT_VERSION; \
    fi \
    # Download the binary and checksum
    && curl -OLSs "https://github.com/gruntwork-io/terragrunt/releases/download/v${VERSION}/terragrunt_linux_amd64" \
    && curl -OLSs "https://github.com/gruntwork-io/terragrunt/releases/download/v${VERSION}/SHA256SUMS" \
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
