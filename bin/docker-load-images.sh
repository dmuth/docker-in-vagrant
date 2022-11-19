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

DIR="vagrant-docker-images"

echo "# Creating directory ${DIR}..."
mkdir -p ${DIR}
cd ${DIR}

echo "# Importing Docker images.  This may take some time..."

for FILE in *.image
do

    IMAGE=$(echo $FILE | sed -e "s/.image$//" -e "s|_|/|")
    FOUND=$(docker images $IMAGE | sed -n '2,$p')

    if test "${FOUND}"
    then
        echo "# Image ${IMAGE} already present, skipping!"
        continue
    fi

    echo "# Loading image ${FILE} (${IMAGE})..."
    cat ${FILE} | zcat | pv | docker load 

done

echo "# Done!"

