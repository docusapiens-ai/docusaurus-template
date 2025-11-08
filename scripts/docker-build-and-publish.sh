#!/bin/bash
# Usage: ./docker-build-and-publish.sh <tag>

set -e

TAG=$1

if [ -z "$TAG" ]; then
  echo "Usage: $0 <tag>"
  exit 1
fi

ROOT_DIR=$(dirname "$0")/..
cd $ROOT_DIR

docker buildx build --platform linux/amd64 -t docusapiens-api:$TAG .
docker tag docusapiens-api:$TAG europe-west1-docker.pkg.dev/docusaurus-ai/docusapiens-ai/api:$TAG
docker push europe-west1-docker.pkg.dev/docusaurus-ai/docusapiens-ai/api:$TAG