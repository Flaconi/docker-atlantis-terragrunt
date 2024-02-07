ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: build test pull tag login push enter

DIR = .
FILE = Dockerfile
IMAGE = "flaconi/atlantis-terragrunt"
TAG = latest

# Versions
ATLANTIS = '0.27.1'
TERRAFORM = '1.7.2'
TERRAGRUNT = '0.55.1'
TERRAGRUNT_ATLANTIS_CONFIG = '1.17.4'
SOPS = '3.8.1'
ONE_PASSWORD_CLI = '2.24.0'

pull:
	docker pull $(shell grep FROM Dockerfile | sed 's/^FROM//g' | sed "s/\$${ATLANTIS}/$(ATLANTIS)/g";)

build:
	docker build \
		--network=host \
		--build-arg ATLANTIS=$(ATLANTIS) \
		--build-arg TERRAFORM=$(TERRAFORM) \
		--build-arg TERRAGRUNT=$(TERRAGRUNT) \
		--build-arg TERRAGRUNT_ATLANTIS_CONFIG=$(TERRAGRUNT_ATLANTIS_CONFIG) \
		--build-arg SOPS=$(SOPS) \
		--build-arg ONE_PASSWORD_CLI=$(ONE_PASSWORD_CLI) \
		-t $(IMAGE) -f $(DIR)/$(FILE) $(DIR)

test:
	docker run --rm --entrypoint atlantis ${IMAGE} version | grep -E '^atlantis v$(ATLANTIS) '
	docker run --rm --entrypoint terraform ${IMAGE} --version | grep -E 'v$(TERRAFORM)$$'
	docker run --rm --entrypoint terragrunt ${IMAGE} --version | grep -E 'v$(TERRAGRUNT)$$'
	docker run --rm --entrypoint terragrunt-atlantis-config ${IMAGE} version | grep -E "$(TERRAGRUNT_ATLANTIS_CONFIG)$$"
	docker run --rm --entrypoint sops ${IMAGE} --version --disable-version-check | grep -E '^sops $(SOPS)$$'
	docker run --rm --entrypoint op ${IMAGE} --version | grep -E '$(ONE_PASSWORD_CLI)$$'

tag:
	docker tag $(IMAGE) $(IMAGE):$(TAG)

login:
ifndef DOCKER_USER
	$(error DOCKER_USER must either be set via environment or parsed as argument)
endif
ifndef DOCKER_PASS
	$(error DOCKER_PASS must either be set via environment or parsed as argument)
endif
	@yes | docker login --username $(DOCKER_USER) --password $(DOCKER_PASS)

push:
	docker push $(IMAGE):$(TAG)

enter:
	docker run --rm --name $(subst /,-,$(IMAGE)) -it --entrypoint=/bin/sh $(ARG) $(IMAGE)
