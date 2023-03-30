DOCKER_IMAGE_NAME = knowit-jk-plugin

build-plugin-image:
	docker build -f argocd-plugin/Dockerfile -t $(DOCKER_IMAGE_NAME) .
	docker tag $(DOCKER_IMAGE_NAME) $(DOCKER_IMAGE_NAME):1.0
load-image-into-kind:
	kind load docker-image knowit-jk-plugin:1.0