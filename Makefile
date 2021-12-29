DOCKER_IMAGE_NAME := 3socha/ci-sample
DOCKER_TAG_NAME := $(shell date +%Y%m%d-%H%M%S)
BUILDX_PLATFORMS := linux/amd64,linux/arm64

all: build

build:
	docker image build --tag $(DOCKER_IMAGE_NAME) .

build-ci:
	docker image build --tag $(DOCKER_IMAGE_NAME) --progress plain .

push:
	docker tag $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_NAME):$(DOCKER_TAG_NAME)
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_TAG_NAME)
	docker push $(DOCKER_IMAGE_NAME):latest

cross-build-ci:
	docker buildx build --platform ${BUILDX_PLATFORMS} --tag ${DOCKER_IMAGE_NAME}:latest --progress plain .

# docker buildx build --platform ${BUILDX_PLATFORMS} --tag ${DOCKER_IMAGE_NAME}:$(DOCKER_TAG_NAME) --progress plain.
# docker buildx create --name multi-arch-builder --use

cross-build-and-push:
	docker buildx build --platform ${BUILDX_PLATFORMS} --tag ${DOCKER_IMAGE_NAME}:latest --progress plain --push .
	docker buildx build --platform ${BUILDX_PLATFORMS} --tag ${DOCKER_IMAGE_NAME}:$(DOCKER_TAG_NAME) --progress plain --push .

test-ci:
	@docker container run \
	  --rm \
	  --net none \
	  -v $(CURDIR):/root/src \
	  $(DOCKER_IMAGE_NAME) \
	  /bin/bash -c "bats --tap /root/src/test.bats"

test:
	docker container run \
	  --rm \
	  --net none \
	  --oom-kill-disable \
	  --pids-limit 1024 \
	  --memory 100m \
	  -v $(CURDIR):/root/src \
	  $(DOCKER_IMAGE_NAME) \
	  /bin/bash -c "bats /root/src/test.bats"
