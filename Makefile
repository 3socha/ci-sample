DOCKER_IMAGE_NAME := 3socha/ci-sample

build: prefetch
	docker image build --tag $(DOCKER_IMAGE_NAME) .

build-ci: prefetch
	docker image build --tag $(DOCKER_IMAGE_NAME) --progress plain .

.PHONY: prefetch
prefetch:
	cd pre/mecab-ipadic/ && sha1sum -c sha1sum.txt || curl -SfL "https://ja.osdn.net/frs/g_redir.php?m=kent&f=mecab/mecab-ipadic/2.7.0-20070801/mecab-ipadic-2.7.0-20070801.tar.gz" -o mecab-ipadic-2.7.0-20070801.tar.gz

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

test-ci:
	@docker container run \
	  --rm \
	  --net none \
	  -v $(CURDIR):/root/src \
	  $(DOCKER_IMAGE_NAME) \
	  /bin/bash -c "bats --tap /root/src/test.bats"

clean:
	rm -f pre/mecab-ipadic/*.tar.gz
