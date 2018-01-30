#!/bin/sh

set -e

SOURCE_DIR=/opt/glamering/egwebsite

cd ${SOURCE_DIR}
npm install
gulp
