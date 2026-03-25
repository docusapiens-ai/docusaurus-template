IMAGE_NAME  = docusaurus-template
REGISTRY    = europe-west1-docker.pkg.dev/docusaurus-ai/docusapiens-ai
PORT        = 8000
TAG        ?= latest

.PHONY: help install generate-config local-build serve \
	docker-build-local docker-build docker-run docker-up docker-stop docker-clean docker-publish

# Default target
.DEFAULT_GOAL := help

## Show this help message
help:
	@echo ""
	@echo "Usage: make <target> [VAR=value ...]"
	@echo ""
	@echo "Development"
	@awk 'prev ~ /^## / && /^[a-zA-Z_-]+:/ { \
		printf "  \033[36m%-22s\033[0m %s\n", $$1, substr(prev, 4); \
		prev="" \
	} { prev=$$0 }' $(MAKEFILE_LIST) | grep -v "docker"
	@echo ""
	@echo "Docker"
	@awk 'prev ~ /^## / && /^[a-zA-Z_-]+:/ { \
		printf "  \033[36m%-22s\033[0m %s\n", $$1, substr(prev, 4); \
		prev="" \
	} { prev=$$0 }' $(MAKEFILE_LIST) | grep "docker"
	@echo ""
	@echo "Variables"
	@echo "  REPO        Git URL (required for local-build)"
	@echo "  BRANCH      Branch to clone          (default: main)"
	@echo "  DOCS_PATH   Sub-directory with docs  (default: repo root)"
	@echo "  SITE_NAME   Site title               (default: \"Local Build\")"
	@echo "  SITE_ID     Site identifier          (default: local)"
	@echo "  SITE_URL    Canonical URL            (default: http://localhost:8000)"
	@echo "  TAG         Docker image tag         (default: latest)"
	@echo ""

# ── Development ───────────────────────────────────────────────────────────────

## Install dependencies with Bun
install:
	bun install

## Generate docusaurus.config.js from the Handlebars template
generate-config:
	@test -n "$(REPO)" || (echo "Error: REPO is required. Example: REPO=https://github.com/owner/repo make generate-config" && exit 1)
	bun run generate-config \
		--site-name "$(or $(SITE_NAME),Local Build)" \
		--site-id   "$(or $(SITE_ID),local)" \
		--site-url  "$(or $(SITE_URL),http://localhost:8000)" \
		--github-repo "$(shell echo "$(REPO)" | sed 's|.*github.com/||; s|\.git$$||')"

## Build a remote repo locally inside Docker (emulates Cloud Build pipeline)
local-build:
	@test -n "$(REPO)" || (echo "Error: REPO is required. Example: REPO=https://github.com/owner/repo make local-build" && exit 1)
	./scripts/local-build.sh \
		--repo "$(REPO)" \
		$(if $(BRANCH),--branch "$(BRANCH)") \
		$(if $(DOCS_PATH),--docs-path "$(DOCS_PATH)") \
		$(if $(SITE_NAME),--site-name "$(SITE_NAME)") \
		$(if $(SITE_ID),--site-id "$(SITE_ID)") \
		$(if $(SITE_URL),--site-url "$(SITE_URL)")
	bun run serve

## Serve the existing build/ directory locally with Bun
serve:
	bun run serve

# ── Docker ────────────────────────────────────────────────────────────────────

## Build the local pipeline image (Dockerfile.local) — done automatically by local-build
docker-build-local:
	docker build -f Dockerfile.local -t docusaurus-template-local .

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
