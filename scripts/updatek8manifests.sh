#!/bin/bash

# Check args
if [ $# -ne 3 ]; then
  echo "Usage: $0 <GITHUB_REPO_URL> <IMAGE_NAME> <IMAGE_TAG>"
  exit 1
fi

GITHUB_REPO_URL=$1
IMAGE_NAME=$2
IMAGE_TAG=$3

# Ensure PAT_TOKEN is set
if [ -z "$PAT_TOKEN" ]; then
  echo "Error: PAT_TOKEN env variable is not set."
  exit 1
fi

# Extract repo name from URL (used to cd later)
REPO_NAME=$(basename "$GITHUB_REPO_URL" .git)

# Clone repo using PAT
echo "Cloning repo..."
git clone https://${PAT_TOKEN}@${GITHUB_REPO_URL} || {
  echo "Failed to clone repo"; exit 1;
}

cd "$REPO_NAME" || {
  echo "Failed to cd into repo"; exit 1;
}

# Update manifest with new image tag
echo "Updating manifests with image: $IMAGE_NAME:$IMAGE_TAG"
find . -type f -name "*.yaml" -exec sed -i "s|image: $IMAGE_NAME:.*|image: $IMAGE_NAME:$IMAGE_TAG|g" {} \;

# Commit and push changes
git config user.name "github-actions"
git config user.email "github-actions@github.com"

git add .
git commit -m "Update image to $IMAGE_NAME:$IMAGE_TAG"
git push origin main
