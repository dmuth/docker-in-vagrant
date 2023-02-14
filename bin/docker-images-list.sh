#!/bin/bash
#
# This script dumps all of our Docker images to a directory on disk.
# That way, they can be reloaded when a new Vagrant instance is built.
#

# Fail on error or if a command in a pipe fails
set -e
set -o pipefail

# Change to our script's parent directory
pushd $(dirname $0)/..  > /dev/null

FILTER=".*"
DIR="vagrant-docker-images"

echo "# Creating directory $(realpath ${DIR})..."
mkdir -p ${DIR}
cd ${DIR}

ls -l


