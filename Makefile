DOCKER_IMAGE_NAME := 3socha/ci-sample
all: build

build:
	DOCKER_BUILDKIT=1 docker image build --tag $(DOCKER_IMAGE_NAME) --progress plain .

cross-build:
	@docker buildx create --name mybuilder --use
	@docker buildx build --platform ${BUILDX_PLATFORMS} --tag ${DOCKER_IMAGE_NAME} .

# push:
# 	docker push $(DOCKER_IMAGE_NAME)

test:
	docker container run \
	  --rm \
	  -v $(CURDIR):/root/src \
	  $(DOCKER_IMAGE_NAME) \
	  /bin/bash -c "bats /root/src/test.bats"
