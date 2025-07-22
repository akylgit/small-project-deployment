#!/bin/bash

set -e  # Exit on error
set -x  # Print commands for debugging

# Usage check
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <github-repo-url> <image-name> <image-tag>"
  echo "Example: $0 https://github.com/akylgit/small-project-deployment.git mydockerhubuser/k8s-demo v1.0.0"
  exit 1
fi

GITHUB_REPO_URL=$1    # GitHub HTTPS repo URL
IMAGE_NAME=$2         # Docker image name
IMAGE_TAG=$3          # New tag

# Use PAT_TOKEN instead of GITHUB_TOKEN
if [ -z "$PAT_TOKEN" ]; then
  echo "Error: PAT_TOKEN env variable is not set."
  exit 1
fi

# Inject token into the repo URL
AUTH_REPO_URL=$(echo "$GITHUB_REPO_URL" | sed "s#https://#https://${PAT_TOKEN}@#")

# Clone to temporary folder
TEMP_DIR=$(mktemp -d)
git clone "$AUTH_REPO_URL" "$TEMP_DIR"
cd "$TEMP_DIR" || exit

# Update deployment.yaml
sed -i "s|image:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" kubernetes/deployment.yaml

# Git config
git config user.name "automation-bot"
git config user.email "bot@example.com"

# Commit + Push
git add kubernetes/deployment.yaml
git commit -m "Update image to ${IMAGE_NAME}:${IMAGE_TAG}"
git push

# Cleanup
rm -rf "$TEMP_DIR"
