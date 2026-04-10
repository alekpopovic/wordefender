SHELL := /bin/bash

HARBOR_REGISTRY=harbor.codepop.tech
HARBOR_PROJECT=wp
SERVICE_NAME=wordefender
TAG=0.0.1
IMAGE=${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${SERVICE_NAME}:${TAG}

.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

## build: build docker image
.PHONY: build
build:
	docker build \
	-t ${IMAGE} .

## push: push to harbor.codepop.tech docker registry
.PHONY: push
push:
	docker push ${IMAGE}

## ci: continuous integration check
.PHONY: ci
ci:
	docker run --rm -it \
	--env-file .env \
    --network host \
	--name ${SERVICE_NAME}-puma \
  ${IMAGE} \
  bundle exec ./bin/ci

## test: tests check
.PHONY: test
test:
	docker run --rm -it \
	--env-file .env \
    --network host \
	--name ${SERVICE_NAME}-puma \
  ${IMAGE} \
  bundle exec rspec

## puma: start puma in cluster mode
.PHONY: puma
puma:
	docker run --rm -it \
	--env-file .env \
    --network host \
	--name ${SERVICE_NAME}-puma \
  ${IMAGE} \
  bundle exec puma -C config/puma.rb
