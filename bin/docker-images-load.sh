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


echo "# Importing Docker images from $(realpath .)."
echo "# This may take some time..."

for FILE in *.image
do

    #
    # Skip anything that doesn't match our filter.
    #
    if [[ ! ${FILE} =~ ${FILTER} ]]
    then
        continue
    fi

    if test ! -f "${FILE}"
    then
        echo "! File '${FILE}' does not exist or is not a regular file."
        continue
    fi

    IMAGE=$(echo $FILE | sed -e "s/.image$//" -e "s|_|/|g")
    FOUND=$(docker images $IMAGE | sed -n '2,$p')

    TIME_IMAGE="N/A"
    TIME_T_IMAGE=0

    if test "${FOUND}"
    then
        TIME_IMAGE=$(docker inspect -f '{{ .Created }}' ${IMAGE})
        TIME_T_IMAGE=$(python3 -c "import time; import dateutil.parser as parser; retval = time.mktime(parser.parse('${TIME_IMAGE}').timetuple()); print(f'{int(retval)}')")
    fi

    TIME_FILE=$(date -r ${FILE})
    TIME_T_FILE=$(python3 -c "import time; import dateutil.parser as parser; retval = time.mktime(parser.parse('${TIME_FILE}').timetuple()); print(f'{int(retval)}')")

    if test "${TIME_T_FILE}" -le "${TIME_T_IMAGE}"
    then
        echo -e "Image ${IMAGE}:\n\tFile time of ${TIME_FILE}\n\t\t<= image time of ${TIME_IMAGE}, skipping!"
        continue
    fi

    if test "${DRY_RUN}"
    then
        echo "# DRY_RUN enabled, skipping image '${IMAGE}'..."
        continue
    fi

    echo "# Loading image ${FILE} (${IMAGE})..."
    cat ${FILE} | zcat | pv | docker load 

    #
    # After successfully loading an image, let's get the time that image was created, 
    # and update the file time to match that, so that there aren't more attempts to 
    # load the same image on future runs.
    #
    TIME_IMAGE=$(docker inspect -f '{{ .Created }}' ${IMAGE})
    TIME_T_IMAGE=$(python3 -c "import time; import dateutil.parser as parser; retval = time.mktime(parser.parse('${TIME_IMAGE}').timetuple()); print(f'{int(retval)}')")

    TIME_DATE_IMAGE=$(date -r $TIME_T_IMAGE)
    touch -t "$(date -r ${TIME_T_IMAGE} +'%Y%m%d%H%M.%S')" ${FILE}

done

echo "# Done!"

