default:
	docker build . -t dm
	docker run dm --rm | kubectl apply -f -