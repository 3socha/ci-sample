
all: build

build:
	DOCKER_BUILDKIT=1 docker image build --tag 3socha/ci-sample --progress plain .
