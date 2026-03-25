#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# local-build.sh
# Host-side orchestrator: builds the pipeline image (Dockerfile.local) and
# runs it inside Docker, mounting ./build so output lands on the host.
#
# The actual pipeline steps (clone, copy, generate-config, build) live in
# scripts/pipeline.sh, which runs as the container's entrypoint.
#
# Usage:
#   ./scripts/local-build.sh \
#     --repo      https://github.com/owner/repo \
#     --branch    main \          # optional, default: main
#     --docs-path docs/ \         # optional sub-directory inside the repo
#     --site-name "My Docs" \     # optional
#     --site-id   "site-123" \    # optional
#     --site-url  "https://docs.example.com"  # optional
# ------------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE="docusaurus-template-local"

# -- Defaults ------------------------------------------------------------------
REPO_URL=""
BRANCH="main"
DOCS_PATH=""
SITE_NAME="Local Build"
SITE_ID="local"
SITE_URL="http://localhost:8000"

# -- Parse arguments -----------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)       REPO_URL="$2";   shift 2 ;;
    --branch)     BRANCH="$2";     shift 2 ;;
    --docs-path)  DOCS_PATH="$2";  shift 2 ;;
    --site-name)  SITE_NAME="$2";  shift 2 ;;
    --site-id)    SITE_ID="$2";    shift 2 ;;
    --site-url)   SITE_URL="$2";   shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$REPO_URL" ]]; then
  cat >&2 <<EOF
Error: --repo is required.
Usage: $0 --repo https://github.com/owner/repo \\
          [--branch main] [--docs-path docs/] \\
          [--site-name "..."] [--site-id "..."] [--site-url "..."]
EOF
  exit 1
fi

# -- Build pipeline image ------------------------------------------------------
echo "--- Building pipeline image (Dockerfile.local)..."
docker build -f "$TEMPLATE_DIR/Dockerfile.local" -t "$IMAGE" "$TEMPLATE_DIR"

# -- Run pipeline inside container ---------------------------------------------
echo ""
echo "--- Running pipeline inside Docker..."
mkdir -p "$TEMPLATE_DIR/build"
docker run --rm \
  -e REPO_URL="$REPO_URL" \
  -e BRANCH="$BRANCH" \
  -e DOCS_PATH="$DOCS_PATH" \
  -e SITE_NAME="$SITE_NAME" \
  -e SITE_ID="$SITE_ID" \
  -e SITE_URL="$SITE_URL" \
  -v "$TEMPLATE_DIR/build":/output \
  "$IMAGE"

echo ""
echo "Build complete -> $TEMPLATE_DIR/build"
