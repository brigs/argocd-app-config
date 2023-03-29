DOCKER_IMAGE_NAME = knowit-jk-plugin
DOCKER_REGISTRY = localhost:6000

build-plugin-image:
	docker build -f argocd-plugin/Dockerfile -t $(DOCKER_IMAGE_NAME) .
	docker tag $(DOCKER_IMAGE_NAME) $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):1.0
	docker push $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):1.0
load-image-into-kind:
	kind load docker-image knowit-jk-container