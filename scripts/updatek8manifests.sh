#!/bin/bash

set -e
set -x

if [ $# -ne 3 ]; then
  echo "Usage: $0 <service-name> <image-name> <tag>"
  exit 1
fi

SERVICE_NAME="$1"
IMAGE_NAME="$2"
TAG="$3"

# Clone without token first
git clone https://github.com/akylgit/small-project-deployment.git /tmp/temp_repo
cd /tmp/temp_repo

# Set remote URL with token for pushing
git remote set-url origin https://${GITHUB_PAT}@github.com/akylgit/small-project-deployment.git

sed -i "s|image:.*|image: ${IMAGE_NAME}:${TAG}|g" kubernetes/deployment.yaml

git config user.email "ci@automation.com"
git config user.name "GitHub Actions CI"

COMMIT_DATE=$(date +"%Y-%m-%d %H:%M:%S")
git add .
git commit -m "Update deployment image to ${IMAGE_NAME}:${TAG} at ${COMMIT_DATE}"

git push

rm -rf /tmp/temp_repo
