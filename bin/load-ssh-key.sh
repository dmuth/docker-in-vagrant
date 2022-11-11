#!/bin/bash
#
# Load our SSH key into SSH-agent
#

# Fail on error or if a command in a pipe fails
set -e
set -o pipefail

# Change to our script's parent directory
pushd $(dirname $0)/..  > /dev/null

echo "# Adding SSH key to ssh-agent..."
ssh-add $(pwd)/.vagrant/machines/default/virtualbox/private_key && RETVAL=$? || RETVAL=$?

if test ${RETVAL} -ne 0
then
    echo "! "
    echo "! Unable to add the SSH key for this VM to ssh-agent."
    echo "! "
    echo "! Please make sure that ssh-agent is running and your environment variables for it as set correctly."
    echo "! "
    echo "! In a pinch, try this: eval \$(ssh-agent)"
    echo "! "
    exit ${RETVAL}
fi

if test ! "${DOCKER_HOST}"
then
    echo "# "
    echo "# I don't see the \$DOCKER_HOST environment variable set!"
    echo "# "
    echo "# Be sure to add the following to .bashrc or similar so that "
    echo "# your Docker CLI tools know where to talk to..."
    echo "# "
    echo "# export DOCKER_HOST=ssh://vagrant@127.0.0.1:2222"
    echo "# "
fi

echo "# Done!"

