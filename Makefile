DOCKER_IMAGE_NAME := 3socha/ci-sample

all: build

build:
	docker image build --tag $(DOCKER_IMAGE_NAME) .

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
