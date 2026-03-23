IMAGE_NAME  = docusaurus-template
REGISTRY    = europe-west1-docker.pkg.dev/docusaurus-ai/docusapiens-ai
PORT        = 8000
TAG        ?= latest

.PHONY: install start build serve clear generate-config \
        docker-build docker-run docker-up docker-stop docker-clean docker-publish

## Install dependencies with Bun
install:
	bun install

## Start development server (hot reload)
start:
	bun run start

## Build the static site (uses SWC + Rspack via @docusaurus/faster)
build:
	bun run build

## Serve the previously built site locally
serve:
	bun run serve

## Clear Docusaurus cache and build artifacts
clear:
	bun run clear

## Generate docusaurus.config.js from the Handlebars template
generate-config:
	bun run generate-config

# ── Docker ────────────────────────────────────────────────────────────────────

## Build the production Docker image
docker-build:
	docker build -t $(IMAGE_NAME) .

## Run the production image locally
docker-run:
	docker run --rm -it \
		--name $(IMAGE_NAME) \
		-p $(PORT):3000 \
		$(IMAGE_NAME)

## Build and run in one step
docker-up: docker-build docker-run

## Stop the running container
docker-stop:
	docker stop $(IMAGE_NAME)

## Remove the image
docker-clean:
	docker rmi $(IMAGE_NAME)

## Build for linux/amd64, tag and push to Artifact Registry  (TAG=x.y.z make docker-publish)
docker-publish:
	docker buildx build --platform linux/amd64 -t $(IMAGE_NAME):$(TAG) .
	docker tag $(IMAGE_NAME):$(TAG) $(REGISTRY)/$(IMAGE_NAME):$(TAG)
	docker push $(REGISTRY)/$(IMAGE_NAME):$(TAG)
