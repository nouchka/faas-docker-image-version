DOCKER_IMAGE=docker-image-version
DOCKER_NAMESPACE=nouchka

.DEFAULT_GOAL := build

run:
	docker run $(DOCKER_NAMESPACE)/$(DOCKER_IMAGE) /usr/bin/docker-registry-inspect nouchka/symfony latest

test: build run

build:
	faas-cli build -f $(DOCKER_IMAGE).yml 

invoke:
	faas-cli invoke -f $(DOCKER_IMAGE).yml $(DOCKER_IMAGE)

rm:
	faas-cli rm -f $(DOCKER_IMAGE).yml

deploy:
	faas-cli deploy -f $(DOCKER_IMAGE).yml

test: build rm deploy invoke

docker-test: build run
