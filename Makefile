IMAGE_NAME  = docusaurus-template
REGISTRY    = europe-west1-docker.pkg.dev/docusaurus-ai/docusapiens-ai
PORT        = 8000
TAG        ?= latest

.PHONY: install start build serve clear generate-config local-build \
        docker-build docker-build-builder docker-run docker-up docker-stop docker-clean docker-publish

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

## Build a remote repo locally inside Docker (emulates Cloud Build, no upload)
## Usage: REPO=https://github.com/owner/repo make local-build
##        REPO=... BRANCH=dev DOCS_PATH=docs SITE_NAME="My Docs" make local-build
local-build:
	@test -n "$(REPO)" || (echo "Error: REPO is required. Usage: REPO=https://github.com/owner/repo make local-build" && exit 1)
	./scripts/local-build.sh \
		--repo "$(REPO)" \
		$(if $(BRANCH),--branch "$(BRANCH)") \
		$(if $(DOCS_PATH),--docs-path "$(DOCS_PATH)") \
		$(if $(SITE_NAME),--site-name "$(SITE_NAME)") \
		$(if $(SITE_ID),--site-id "$(SITE_ID)") \
		$(if $(SITE_URL),--site-url "$(SITE_URL)")

## Pre-build the Docker local pipeline image (done automatically by local-build)
docker-build-builder:
	docker build -f Dockerfile.local -t docusaurus-template-local .

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
