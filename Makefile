ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: build rebuild pull tag login push enter

DIR = .
FILE = Dockerfile
IMAGE = "flaconi/atlantis-terragrunt"
TAG = latest
TF_VERSION = '0.12.29'
TG_VERSION = '0.21.7'

pull:
	docker pull $(shell grep FROM Dockerfile | sed 's/^FROM//g';)

build:
	docker build --build-arg TERRAFORM_VERSION=$(TF_VERSION) --build-arg TERRAGRUNT_VERSION=$(TG_VERSION) -t $(IMAGE) -f $(DIR)/$(FILE) $(DIR)

rebuild: pull
	docker build --no-cache -t $(IMAGE) -f $(DIR)/$(FILE) $(DIR)

tag:
	docker tag $(IMAGE) $(IMAGE):$(TAG)

login:
ifndef DOCKER_USER
	$(error DOCKER_USER must either be set via environment or parsed as argument)
endif
ifndef DOCKER_PASS
	$(error DOCKER_PASS must either be set via environment or parsed as argument)
endif
	yes | docker login --username $(DOCKER_USER) --password $(DOCKER_PASS)

push:
	@$(MAKE) tag TAG=$(TAG)
	docker push $(IMAGE):$(TAG)

enter:
	docker run --rm --name $(subst /,-,$(IMAGE)) -it --entrypoint=/bin/sh $(ARG) $(IMAGE)
