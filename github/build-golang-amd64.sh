#!/bin/bash -xe

[ -z "${GOLANG_VERSION}" ] && echo "Need to set GOLANG_VERSION" && exit 1
[ -z "${OPENCV_VERSION}" ] && echo "Need to set OPENCV_VERSION" && exit 1

# Build deploy docker image
GIT_COMMIT_ID=$(git rev-parse HEAD | cut -c1-7)
IMAGE="774915305292.dkr.ecr.us-west-2.amazonaws.com/golang-with-opencv:golang-${GOLANG_VERSION}-opencv-${OPENCV_VERSION}-amd64"
AWS_CLI_VERSION=$(aws --version 2>&1 | cut -d " " -f1 | cut -d "/" -f2 | cut -c 1)
AWS_REGION=us-west-2
ECR_REGISTRY=774915305292.dkr.ecr.us-west-2.amazonaws.com
docker buildx build --pull --load \
  --platform linux/amd64 \
  -t "${IMAGE}" \
  --build-arg GOLANG_VERSION=$GOLANG_VERSION \
  --build-arg OPENCV_VERSION=$OPENCV_VERSION \
  -f Dockerfile.umbo.golang .
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REGISTRY"

# Push docker images
docker push "${IMAGE}"
docker rmi -f "${IMAGE}"
