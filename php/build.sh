#!/bin/bash
help() {
  echo "Use of push: "
  echo
  echo ". $0 <gazie-version>"
  echo ". Example: $0 9.05"
  return 1
}

if [ "$1" == "" ]; then
  help
  exit 1
fi

BUILD_VERSION=$1
docker build -t docker.rvmgroup.it/gazie-php:$BUILD_VERSION --build-arg BUILD_VERSION=$BUILD_VERSION .

