IMAGE ?= ghcr.io/ORGA/REPO/app
TAG ?= dev

.PHONY: help build run test push k8s-dev

help:
	@echo "make build|run|test|push|k8s-dev"

build:
	docker build -f app/Dockerfile -t $(IMAGE):$(TAG) .

run:
	docker run --rm -p 8080:8080 -e ENVIRONMENT=local $(IMAGE):$(TAG)

test:
	pip install -r app/requirements.txt pytest && pytest -q

push:
	docker push $(IMAGE):$(TAG)

k8s-dev:
	kustomize build infra/k8s/overlays/dev | kubectl apply -f -