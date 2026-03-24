#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# pipeline.sh
# Container entrypoint: executes the 4-step Docusaurus build pipeline.
# Runs INSIDE the Docker container built from Dockerfile.local.
# Configuration is passed via environment variables (set by local-build.sh).
#
# Steps:
#   1. Clone the user's repo
#   2. Copy markdown files into the template's docs/ directory
#   3. Generate docusaurus.config.js from the Handlebars template
#   4. Build the static site and export the output to /output
#
# Required env var:
#   REPO_URL   — full Git URL of the repo to clone
# Optional env vars (all have defaults):
#   BRANCH, DOCS_PATH, SITE_NAME, SITE_ID, SITE_URL
# ------------------------------------------------------------------------------
set -euo pipefail

TEMPLATE_DIR="/app"

BRANCH="${BRANCH:-main}"
DOCS_PATH="${DOCS_PATH:-}"
SITE_NAME="${SITE_NAME:-Local Build}"
SITE_ID="${SITE_ID:-local}"
SITE_URL="${SITE_URL:-http://localhost:8000}"

if [[ -z "${REPO_URL:-}" ]]; then
  echo "Error: REPO_URL environment variable is required." >&2
  exit 1
fi

# Derive GITHUB_REPO (owner/repo) from the URL
GITHUB_REPO=$(echo "$REPO_URL" | sed 's|.*github.com/||; s|\.git$||')

# -- Cleanup trap --------------------------------------------------------------
WORK_DIR=""
cleanup() {
  [[ -n "${WORK_DIR:-}" ]] || return 0
  echo ""
  echo "Cleaning up temporary directory $WORK_DIR..."
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

WORK_DIR="$(mktemp -d)"
CLONE_DIR="$WORK_DIR/user-repo"
DOCS_DEST="$TEMPLATE_DIR/docs"

echo "================================================="
echo "  Docusaurus Pipeline Build"
echo "  Repo:      $REPO_URL ($BRANCH)"
echo "  Docs path: ${DOCS_PATH:-(root)}"
echo "  Site name: $SITE_NAME"
echo "================================================="

# -- Step 1: Clone -------------------------------------------------------------
echo ""
echo "[1/4] Cloning $REPO_URL (branch: $BRANCH)..."
git clone --branch="$BRANCH" --depth=1 --single-branch "$REPO_URL" "$CLONE_DIR"

# -- Step 2: Copy markdown files -----------------------------------------------
echo ""
echo "[2/4] Copying markdown files..."

SOURCE_DIR="$CLONE_DIR"
if [[ -n "$DOCS_PATH" ]]; then
  CANDIDATE="$CLONE_DIR/$DOCS_PATH"
  if [[ -d "$CANDIDATE" ]]; then
    SOURCE_DIR="$CANDIDATE"
  else
    echo "Warning: DOCS_PATH '$DOCS_PATH' not found, falling back to repo root" >&2
  fi
fi

find "$DOCS_DEST" -type f \( -name "*.md" -o -name "*.mdx" \) -delete 2>/dev/null || true

MATCH_COUNT=$(find "$SOURCE_DIR" -type f \( -name "*.md" -o -name "*.mdx" \) | wc -l | tr -d ' ')
if [[ "$MATCH_COUNT" -eq 0 ]]; then
  echo "Warning: no markdown files found in $SOURCE_DIR" >&2
else
  (cd "$SOURCE_DIR" && find . -type f \( -name "*.md" -o -name "*.mdx" \) | while read -r file; do
    dest="$DOCS_DEST/$file"
    mkdir -p "$(dirname "$dest")"
    cp "$file" "$dest"
  done)
  echo "Copied $MATCH_COUNT markdown files -> docs/"
fi

# -- Step 3: Generate config ---------------------------------------------------
echo ""
echo "[3/4] Generating docusaurus.config.js..."
cd "$TEMPLATE_DIR"
bun run generate-config \
  --site-name   "$SITE_NAME" \
  --site-id     "$SITE_ID" \
  --site-url    "$SITE_URL" \
  --github-repo "$GITHUB_REPO"

# -- Step 4: Build -------------------------------------------------------------
echo ""
echo "[4/4] Building site..."
NODE_ENV=production bun run build

find build -type f \( -name "*.map" -o -name "*.LICENSE.txt" -o -name "*.log" \) -delete
find build -type f -name ".DS_Store" -delete

# Export build output to the /output mount (host volume)
echo ""
echo "Exporting build output to /output..."
cp -r build/. /output/

echo ""
echo "================================================="
echo "  Build complete."
echo "================================================="
