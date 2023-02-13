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

echo "# Exporting Docker images.  This may take some time..."

for IMAGE in $(docker images | sed -n '2,$p' | awk '{print $1 ":" $2}')
do

    FILE=$(echo "${IMAGE}" | sed -e "s|/|_|")
    FILE_TMP="${FILE}.tmp"
    FILE_IMAGE="${FILE}.image"

    rm -fv "${FILE_TMP}"

    if test -f "${FILE_IMAGE}"
    then
        echo "# Skipping saved image ${IMAGE}..."
        continue
    fi

    echo "# Saving image ${IMAGE}..."
    docker save "${IMAGE}" | pv | gzip > "${FILE_TMP}"
    mv "${FILE_TMP}" "${FILE_IMAGE}"

done

echo "# Done!"

