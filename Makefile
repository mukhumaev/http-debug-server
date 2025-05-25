IMAGE_NAME = http-debug-server
TAG ?= latest
PORT ?= 5000
AUTHOR ?= mukhumaev
DOCKER_REPO = $(AUTHOR)/$(IMAGE_NAME)

.PHONY: all build build-image start start-container build-all clean release help

all: help

build:  ## Build the local Go application
	CGO_ENABLED=0 GOOS=linux go build -o $(IMAGE_NAME) $(IMAGE_NAME).go

build-image:  ## Builds the Docker image for the application with the specified tag.
	docker build -t $(DOCKER_REPO):$(TAG) .

start: build  ## Start local Go application
	./$(IMAGE_NAME)

start-container: build-image ## Start the application inside Docker container
	docker run -it --rm -p 127.0.0.1:$(PORT):5000 $(DOCKER_REPO):$(TAG)

build-all: build build-image  ## Build the application and the Docker image

clean: ## Removes the Docker image and cleans up unused Docker resources to free up space.
	@echo "Removing Docker image: $(DOCKER_REPO):$(TAG)"
	@docker rmi $(DOCKER_REPO):$(TAG) || true
	@echo "Pruning unused Docker resources..."
	@docker system prune -f
	@echo "Removing local binary..."
	@rm -f $(IMAGE_NAME)

release: build-image ## Pushes the built Docker image to the specified Docker repository.
	@echo "Pushing Docker image: $(DOCKER_REPO):$(TAG)"
	docker push $(DOCKER_REPO):$(TAG)

help: ## Show this info
	@echo -e '\n\033[1mSupported targets:\033[0m\n'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[33m%-12s\033[0m %s\n", $$1, $$2}'
	@echo -e ''
