#!/bin/bash
set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHARTS=("siterm-fe" "siterm-agent" "siterm-debugger")
BUILD_DIR="$BASE_DIR/builds"
REPO_URL="https://sdn-sense.github.io/helm-charts/builds"

# Require $1 (NEW_VERSION)
if [ -z "$1" ]; then
  echo "Usage: $0 <chart-version> [image-tag]"
  echo "Error: <chart-version> argument is required. If image-tag not specified, it will use same as chart-version"
  exit 1
fi

# Ensure builds directory exists
mkdir -p "$BUILD_DIR"

NEW_VERSION=$1
IMAGE_TAG=${2:-$NEW_VERSION}

if [ -n "$NEW_VERSION" ]; then
  echo "Updating chart version: $NEW_VERSION"
  echo "Using image tag: $IMAGE_TAG"
  for CHART in "${CHARTS[@]}"; do
    CHART_PATH="$BASE_DIR/$CHART"
    CHART_YAML="$CHART_PATH/Chart.yaml"
    HELPERS_TPL="$CHART_PATH/templates/_helpers.tpl"

    if [ -f "$CHART_YAML" ]; then
      echo "Updating version in $CHART_YAML"
      sed -i '' -E "s/^version: .*/version: $NEW_VERSION/" "$CHART_YAML"
    fi

    if [ -f "$HELPERS_TPL" ]; then
      echo "Updating hardcoded image tag in $HELPERS_TPL"
      sed -i '' -E "s|(sdnsense/$CHART:)[0-9A-Za-z._-]+\"[ \t]*\}\}[ \t]*\$|\1$IMAGE_TAG\" }}|g" "$HELPERS_TPL"
    fi
  done
fi

for CHART in "${CHARTS[@]}"; do
  echo "Packaging $CHART..."
  helm package "$BASE_DIR/$CHART" --destination "$BUILD_DIR"
done

echo "Updating Helm repo index..."
helm repo index "$BUILD_DIR" --url "$REPO_URL" --merge "$BASE_DIR/index.yaml"
mv "$BUILD_DIR/index.yaml" "$BASE_DIR/index.yaml"

echo "======================================================================================"
echo "Charts built into $BUILD_DIR and index.yaml updated."
echo "To commit and push, run:"
echo 'git commit -a -m "Add index and new chart versions"'
echo 'git push origin'
