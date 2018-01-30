#!/usr/bin/env bash
# Created by g7tianyi on 12/10/2017

set -e

pushd $(dirname $0) > /dev/null
SCRIPTPATH=$(pwd -P)
popd > /dev/null
SCRIPTFILE=$(basename $0)

LOGLINE="============================================================"

function log() {
  NOW=$(date '+%Y%m%d%H%M%S')
  echo ${LOGLINE}
  echo "${NOW} - $1"
  echo ${LOGLINE}
}

# ============================================================

SOURCE_DIR=${SCRIPTPATH}/..
ROOTFS_DIR=${SOURCE_DIR}/rootfs

BUILDER_IMAGE_NAME=glamering/egwebbuilder
BUILDER_DOCKER_FILE=${ROOTFS_DIR}/builder/Dockerfile

EGWEBSITE_IMAGE_NAME=glamering/egwebsite
EGWEBSITE_BUILD_DIR=/opt/glamering/egwebsite
EGWEBSITE_OUTPUT_DIR=${SOURCE_DIR}/dist
EGWEBSITE_DOCKER_FILE=${ROOTFS_DIR}/egwebsite/Dockerfile

DATENOW=$(date '+%y%m%d%H%M%S')
RELEASE_VERSION=$(printf "%x" ${DATENOW})
BUILDER_VERSION=${RELEASE_VERSION}

# ============================================================

function buildBuilder() {

  log "Build Docker Image ${BUILDER_IMAGE_NAME}:${BUILDER_VERSION}"

  cd ${ROOTFS_DIR}
  mkdir -p ${ROOTFS_DIR}/opt/glamering
  cp ${SCRIPTPATH}/build-app.sh ${ROOTFS_DIR}/opt/glamering/
  docker build -t ${BUILDER_IMAGE_NAME}:${BUILDER_VERSION} -f ${BUILDER_DOCKER_FILE} .
}

function checkBuilder() {
  IMAGE=$(docker images | grep ${BUILDER_IMAGE_NAME} | awk '{print $1}')
  if [ "X${IMAGE}" == "X" ]; then
    buildBuilder
  else
    BUILDER_VERSION=$(docker images | grep ${BUILDER_IMAGE_NAME} | awk '{print $2}' | sort -nr | head -n 1)
  fi
}

function buildImage() {

  log "Build Docker Image ${EGWEBSITE_IMAGE_NAME}"

  docker run --rm \
    -v ${SOURCE_DIR}:${EGWEBSITE_BUILD_DIR} \
    ${BUILDER_IMAGE_NAME}:${BUILDER_VERSION} \
    /opt/glamering/build-app.sh

  rm -rf ${ROOTFS_DIR}/egwebsite/dist
  mkdir -p ${ROOTFS_DIR}/egwebsite/dist
  cp -r ${EGWEBSITE_OUTPUT_DIR}/* ${ROOTFS_DIR}/egwebsite/dist

  cd ${ROOTFS_DIR}/egwebsite
  docker build -t ${EGWEBSITE_IMAGE_NAME} -f ${EGWEBSITE_DOCKER_FILE} .
}

# ============================================================

checkBuilder
buildImage
