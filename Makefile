DOCKER_IMAGE_NAME := 3socha/ci-sample

all: build

build: prefetch
	DOCKER_BUILDKIT=1 docker image build --tag $(DOCKER_IMAGE_NAME) .

build-ci: prefetch
	DOCKER_BUILDKIT=1 docker image build --tag $(DOCKER_IMAGE_NAME) --progress plain .

prefetch:
	./prefetch_files.sh

test:
	docker container run \
		--rm \
		--net none \
		--oom-kill-disable \
		--pids-limit 1024 \
		--memory 100m \
		-v $(CURDIR):/root/src \
		$(DOCKER_IMAGE_NAME) \
		/bin/bash -c "bats --print-output-on-failure /root/src/docker_image.bats"

test-ci:
	@docker container run \
		--rm \
		--net none \
		-v $(CURDIR):/root/src \
		$(DOCKER_IMAGE_NAME) \
		/bin/bash -c "bats --print-output-on-failure --tap /root/src/docker_image.bats"

clean: $(subdirs)
	rm -f prefetched/*/*.gz prefetched/*/*.zip
