ARG ATLANTIS
FROM ghcr.io/runatlantis/atlantis:v${ATLANTIS}

USER root
RUN apk add \
	aws-cli \
	curl \
	make \
	unzip \
	yq

ARG TERRAGRUNT
ARG TERRAFORM
ARG TERRAGRUNT_ATLANTIS_CONFIG
ARG SOPS
ARG ONE_PASSWORD_CLI

###
### Ensure Terraform version is present, linked and validated
###
RUN set -eux \
	&& if [ "${TERRAFORM}" = "latest" ]; then \
		TERRAFORM="$( \
			curl -sS https://releases.hashicorp.com/terraform/ \
			| tac | tac \
			| grep -Eo '/terraform/[0-9]\.[0-9]\.[0-9]/' \
			| grep -Eo '[.0-9]+' \
			| sort -V \
			| tail -1 \
		)"; \
	fi \
	&& if ! terraform version | grep -qE " v${TERRAFORM}\$"; then \
		cd "/tmp" \
		&& curl -sS "https://releases.hashicorp.com/terraform/${TERRAFORM}/terraform_${TERRAFORM}_linux_amd64.zip" -o terraform.zip \
		&& unzip terraform.zip \
		&& rm terraform.zip \
		&& chmod +x terraform \
		&& mv terraform /usr/local/bin/terraform; \
	fi \
	&& terraform --version | grep "v${TERRAFORM}"

###
### Ensure Terragrunt version is present and validated
###
RUN set -eux \
	&& if [ "${TERRAGRUNT}" = "latest" ]; then \
		TERRAGRUNT="$( \
			curl -L -sS --ipv4 https://github.com/gruntwork-io/terragrunt/releases \
			| tac | tac \
			| grep -Eo '"/gruntwork-io/terragrunt/releases/tag/v?[0-9]+\.[0-9]+\.[0-9]+"' \
			| grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' \
			| sort -V \
			| tail -1 \
		)"; \
	fi \
	&& curl -L -sS --ipv4 "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT}/terragrunt_linux_amd64" -o /usr/local/bin/terragrunt \
	&& chmod +x /usr/local/bin/terragrunt \
	&& terragrunt --version | grep "v${TERRAGRUNT}"

###
### Ensure the Terragrunt Atlantis Config is present
###
ADD https://github.com/transcend-io/terragrunt-atlantis-config/releases/download/v${TERRAGRUNT_ATLANTIS_CONFIG}/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG}_linux_amd64 /usr/local/bin/
RUN set -eux \
	&& cd /usr/local/bin \
	&& mv terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG}_linux_amd64 terragrunt-atlantis-config \
	&& chmod +x terragrunt-atlantis-config \
	&& terragrunt-atlantis-config version | grep " ${TERRAGRUNT_ATLANTIS_CONFIG}"

###
### Ensure SOPS version is present and validated
###
RUN set -eux \
	&& if [ "${SOPS}" = "latest" ]; then \
		SOPS="$( \
			curl -L -sS --ipv4 https://github.com/getsops/sops/releases \
			| tac | tac \
			| grep -Eo '"/getsops/sops/releases/tag/v?[0-9]+\.[0-9]+\.[0-9]+"' \
			| grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' \
			| sort -V \
			| tail -1 \
		)"; \
	fi \
	&& cd /usr/local/bin \
	&& curl -L -sS --ipv4 "https://github.com/getsops/sops/releases/download/v${SOPS}/sops-v${SOPS}.linux.amd64" -o sops \
	&& chmod +x sops \
	&& sops --version --disable-version-check | grep " ${SOPS}"

###
### Ensure 1Password CLI version is present, linked and validated
###
RUN set -eux \
	&& if [ "${ONE_PASSWORD_CLI}" = "latest" ]; then \
		ONE_PASSWORD_CLI="$( \
			curl -sS  https://app-updates.agilebits.com/product_history/CLI2 \
			| grep -Eo '"/dist/1P/op2/pkg/v?[0-9]+\.[0-9]+\.[0-9]+/op_linux_amd64"' \
			| grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' \
			| sort -V \
			| tail -1 \
		)"; \
	fi \
	&& cd "/tmp" \
    && curl -sS "https://cache.agilebits.com/dist/1P/op2/pkg/v${ONE_PASSWORD_CLI}/op_linux_amd64_v${ONE_PASSWORD_CLI}.zip" -o op.zip \
    && unzip op.zip \
    && rm op.zip \
    && chmod +x op \
    && mv op /usr/local/bin/op \
    && op --version | grep "${ONE_PASSWORD_CLI}"

USER atlantis
