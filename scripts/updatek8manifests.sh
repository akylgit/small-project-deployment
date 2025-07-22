#!/bin/bash

set -e  # Exit on error
set -x  # Debug output

# Validate input
if [ $# -ne 3 ]; then
  echo "Usage: $0 <service-name> <image-name> <tag>"
  exit 1
fi

SERVICE_NAME="$1"
IMAGE_NAME="$2"
TAG="$3"

# GitHub PAT securely stored in GitHub Actions secrets
REPO_URL="https://${GITHUB_PAT}@github.com/akylgit/small-project-deployment.git"

# Clone the repo to a temp directory
git clone "$REPO_URL" /tmp/temp_repo
cd /tmp/temp_repo

# Update the image in the Kubernetes manifest
sed -i "s|image:.*|image: ${IMAGE_NAME}:${TAG}|g" kubernetes/deployment.yaml

# Configure Git user for CI
git config user.email "ci@automation.com"
git config user.name "GitHub Actions CI"

# Commit with date and time
COMMIT_DATE=$(date +"%Y-%m-%d %H:%M:%S")
git add .
git commit -m "Update ${SERVICE_NAME} image to ${IMAGE_NAME}:${TAG} at ${COMMIT_DATE}"

# Push changes
git push

# Clean up
rm -rf /tmp/temp_repo
