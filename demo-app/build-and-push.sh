#!/bin/bash
set -e

# Configuration
IMAGE_NAME="prague-dashboard"
IMAGE_TAG="${1:-latest}"
REGISTRY="${2:-docker.io/constantinious}"

echo "🐳 Building Docker image..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} demo-app/

echo "📦 Tagging image..."
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

echo "📤 Pushing to registry..."
docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

echo "✅ Image pushed: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "To update Kubernetes deployment:"
echo "kubectl set image deployment/demo-app demo-app=${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -n demo-app"
