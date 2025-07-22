#!/bin/bash

set -e

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <github_repo_url> <image_name> <image_tag>"
  exit 1
fi

GITHUB_REPO_URL=$1
IMAGE_NAME=$2
IMAGE_TAG=$3

if [ -z "$PAT_TOKEN" ]; then
  echo "Error: PAT_TOKEN env variable is not set."
  exit 1
fi

TEMP_DIR=$(mktemp -d)
REPO_NAME=$(basename "$GITHUB_REPO_URL" .git)

echo "Cloning repo..."
git clone "https://$PAT_TOKEN@${GITHUB_REPO_URL#https://}" "$TEMP_DIR/$REPO_NAME"

cd "$TEMP_DIR/$REPO_NAME"

echo "Updating image in deployment.yaml..."
sed -i "s|image: .*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" kubernetes/deployment.yaml

echo "Committing and pushing changes..."
git config user.name "GitHub Actions Bot"
git config user.email "actions@github.com"
git add kubernetes/deployment.yaml
git commit -m "Update image to ${IMAGE_NAME}:${IMAGE_TAG}"
git push origin main
