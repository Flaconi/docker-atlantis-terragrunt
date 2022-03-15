ARG ATLANTIS
FROM ghcr.io/runatlantis/atlantis:v${ATLANTIS}

RUN apk add \
	aws-cli \
	curl \
	make \
	unzip

ARG TERRAGRUNT
ARG TERRAFORM
ARG TERRAGRUNT_ATLANTIS_CONFIG

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
	&& if [ ! -d "/usr/local/bin/tf/versions/${TERRAFORM}" ]; then \
		mkdir "/usr/local/bin/tf/versions/${TERRAFORM}" \
		&& cd "/usr/local/bin/tf/versions/${TERRAFORM}" \
		&& curl -sS "https://releases.hashicorp.com/terraform/${TERRAFORM}/terraform_${TERRAFORM}_linux_amd64.zip" -o terraform.zip \
		&& unzip terraform.zip \
		&& rm terraform.zip \
		&& chmod +x terraform; \
	fi \
	&& ln -sf "/usr/local/bin/tf/versions/${TERRAFORM}/terraform" /usr/local/bin/terraform \
	&& terraform --version | grep "v${TERRAFORM}"

###
### Ensure Terragrunt version is present and validated
###
RUN set -eux \
	&& if [ "${TERRAGRUNT}" = "latest" ]; then \
		TERRAGRUNT="$( \
			curl -L -sS https://github.com/gruntwork-io/terragrunt/releases \
			| tac | tac \
			| grep -Eo '"/gruntwork-io/terragrunt/releases/tag/v?[0-9]+\.[0-9]+\.[0-9]+"' \
			| grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' \
			| sort -V \
			| tail -1 \
		)"; \
	fi \
	&& curl -L -sS "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT}/terragrunt_linux_amd64" -o /usr/local/bin/terragrunt \
	&& chmod +x /usr/local/bin/terragrunt \
	&& terragrunt --version | grep "v${TERRAGRUNT}"

###
### Ensure the Terragrunt Atlantis Config is present
###
ADD https://github.com/transcend-io/terragrunt-atlantis-config/releases/download/v${TERRAGRUNT_ATLANTIS_CONFIG}/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG}_linux_amd64.tar.gz /usr/local/bin/
RUN set -eux \
	&& cd /usr/local/bin \
	&& tar xvzf terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG}_linux_amd64.tar.gz \
	&& mv terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG}_linux_amd64/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG}_linux_amd64 terragrunt-atlantis-config \
	&& chmod +x terragrunt-atlantis-config \
	&& rm -rf terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG}_linux_amd64*

###
### Flaconi customized entrypoint
###
RUN mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-original.sh
# the new docker-entrypoint.sh will do some work and then call the original entry point
ADD data/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ADD data/create_github_user_ssh_key.sh /usr/local/bin/create_github_user_ssh_key.sh
# Creates directory to mount EFS
RUN mkdir /mnt/efs
