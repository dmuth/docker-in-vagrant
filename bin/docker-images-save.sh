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

if test "$1"
then
    if test "$1" == "-h"
    then
        echo "! "
        echo "! Syntax: $0 [ wildcard ] "
        echo "! "
        echo "! wildcard - If set, only images matching this string will be processed."
        echo "! "
        echo "! If the DRY_RUN env variable is set, a dry run will be performed."
        echo "! "
        exit 1

    else
        FILTER=$1

    fi
fi

echo "# Creating directory ${DIR}..."
mkdir -p ${DIR}
cd ${DIR}

if test "${FILTER}" != ".*"
then
    echo "# Filter '${FILTER}' is set, only matching images will be processed!"
fi

echo "# Exporting Docker images from $(realpath .).  This may take some time..."

for IMAGE in $(docker images | sed -n '2,$p' | awk '{print $1 ":" $2}' | grep "${FILTER}")
do
    
    #
    # If there's no tag, remove that part since we won't need it.
    #
    IMAGE=$(echo ${IMAGE} | sed -e "s/:<none>$//")

    FILE=$(echo "${IMAGE}" | sed -e "s|/|_|")
    FILE_TMP="${FILE}.tmp"
    FILE_IMAGE="${FILE}.image"

    rm -fv "${FILE_TMP}"

    #
    # Get our time_t values for the image and the file on disk.
    #
    TIME_IMAGE=$(docker inspect -f '{{ .Created }}' ${IMAGE})
    TIME_T_IMAGE=$(python3 -c "import time; import dateutil.parser as parser; retval = time.mktime(parser.parse('${TIME_IMAGE}').timetuple()); print(f'{int(retval)}')")

    TIME_FILE="N/A"
    TIME_T_FILE=0
    if test -f "${FILE_IMAGE}"
    then
        TIME_FILE=$(date -r ${FILE_IMAGE})
        TIME_T_FILE=$(python3 -c "import time; import dateutil.parser as parser; retval = time.mktime(parser.parse('${TIME_FILE}').timetuple()); print(f'{int(retval)}')")
    fi

    if test "${TIME_T_IMAGE}" -le "${TIME_T_FILE}"
    then
        echo "Image ${IMAGE}: Time of image ${TIME_IMAGE} <= file time of ${TIME_FILE}, skipping!"
        continue
    fi

    if test "${DRY_RUN}"
    then
        echo "# DRY_RUN enabled, skipping image '${IMAGE}'..."
        continue
    fi

    echo "# Saving image ${IMAGE}..."
    docker save "${IMAGE}" | pv | gzip > "${FILE_TMP}"

    #
    # Set the modification time of the file we just created to match that of the Docker image.
    #
    TIME_DATE_IMAGE=$(date -r $TIME_T_IMAGE)
    touch -d "$(date -r ${TIME_T_IMAGE} +'%Y-%m-%dT%H:%M:%S')" ${FILE_TMP}

    mv "${FILE_TMP}" "${FILE_IMAGE}"

done

echo "# Done!"

