#!/bin/bash

# Usage: ./update_k8s.sh <GITHUB_REPO_URL> <IMAGE_NAME> <IMAGE_TAG>

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <GITHUB_REPO_URL> <IMAGE_NAME> <IMAGE_TAG>"
  exit 1
fi

GITHUB_REPO_URL=$1
IMAGE_NAME=$2
IMAGE_TAG=$3

# Check for PAT_TOKEN env variable
if [ -z "$PAT_TOKEN" ]; then
  echo "Error: PAT_TOKEN env variable is not set."
  exit 1
fi

# Extract repo name
REPO_NAME=$(basename -s .git "$GITHUB_REPO_URL")

# Clone the repository using PAT_TOKEN
echo "Cloning repo..."
AUTH_REPO_URL=$(echo "$GITHUB_REPO_URL" | sed "s#https://#https://${PAT_TOKEN}@#")
git clone "$AUTH_REPO_URL"

cd "$REPO_NAME" || { echo "Failed to cd into repo"; exit 1; }

# Update the image tag in the deployment YAML (assumes only one container image line exists)
echo "Updating image to $IMAGE_NAME:$IMAGE_TAG..."
sed -i.bak "s|image:.*|image: $IMAGE_NAME:$IMAGE_TAG|" k8s/deployment.yaml

# Git commit and push
git config user.email "actions@github.com"
git config user.name "GitHub Actions"

git add k8s/deployment.yaml
git commit -m "Update image to $IMAGE_NAME:$IMAGE_TAG"
git push origin main

echo "✅ Image updated and changes pushed."
