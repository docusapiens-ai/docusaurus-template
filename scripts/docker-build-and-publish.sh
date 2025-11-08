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

docker buildx build --platform linux/amd64 -t docusaurus-template:$TAG .
docker tag docusaurus-template:$TAG europe-west1-docker.pkg.dev/docusaurus-ai/docusapiens-ai/docusaurus-template:$TAG
docker push europe-west1-docker.pkg.dev/docusaurus-ai/docusapiens-ai/docusaurus-template:$TAG