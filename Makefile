DOCKER_IMAGE_NAME = knowit-jk-plugin
DOCKER_REGISTRY = localhost:6000
default:
	docker build . -t dm
	docker run dm --rm | kubectl apply -f -
build-plugin-image:
	docker build -f Dockerfile.jkplugin -t $(DOCKER_IMAGE_NAME) .
	docker tag $(DOCKER_IMAGE_NAME) $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):latest
	docker push $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):latest