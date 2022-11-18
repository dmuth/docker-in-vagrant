#!/bin/bash
#
# This script starts up our Vagrant instance.
#

# Fail on error or if a command in a pipe fails
set -e
set -o pipefail

# Change to our script's parent directory
pushd $(dirname $0)/..  > /dev/null

CONFIG_FILE="Vagrantfile"
CONFIG_FILE_SAMPLE="Vagrantfile.sample"
if test ! -f "${CONFIG_FILE}"
then
    echo "# "
    echo "# File ${CONFIG_FILE} does not exist, copying in ${CONFIG_FILE_SAMPLE}..."
    echo "# "
    cp ${CONFIG_FILE_SAMPLE} ${CONFIG_FILE}
fi


#
# Start our VM if it's not already running.
#
RUNNING=$(vagrant status | egrep "default.*running" || true | head -n1)

if ! test "${RUNNING}"
then
    echo "# Starting VM..."
    vagrant up

else
    echo "# VM is already running..."

fi

KEY_PATH="$(pwd)/.vagrant/machines/default/virtualbox/private_key"
echo "# "
echo "# Adding SSH key to ssh-agent..."
echo "# "
ssh-add ${KEY_PATH} && RETVAL=$? || RETVAL=$?

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

echo "# "
echo "# Removing any previous instances of 127.0.0.1:2222 from ~/.ssh/known_hosts..."
echo "# "
sed -i -e '/\[127.0.0.1\]:2222/d' ~/.ssh/known_hosts 

echo "# "
echo "# Testing to see if I can SSH into VM..."
echo "# "
ssh -o StrictHostKeyChecking=no -p 2222 vagrant@127.0.0.1 hostname > /dev/null && RETVAL=$? || RETVAL=$?

if test ${RETVAL} -ne 0
then
    echo "! "
    echo "! We were unable to SSH into the instance!"
    echo "! "
    echo "! Make sure that ssh-agent is running and that the key is listed."
    echo "! If there are too many keys, try running 'ssh-add -d KEY' to remove a key"
    echo "! or 'ssh-add -D' to remove all keys, and then try again!"
    echo "! "
    echo "! "
    exit ${RETVAL}
fi

echo "# ...success!"
echo "# "
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

echo "# Consider adding the following to .bashrc so the SSH key is loaded at login: "
echo "# "
echo "#     ssh-add ${KEY_PATH}"
echo "# "

echo "# "
echo "# Also consider adding the following to \$HOME/.ssh/config: "
echo "# "
echo "# Host 127.0.0.1"
echo "#     ControlMaster auto"
echo "#     ControlPath ~/.ssh/master-%r@%h:%p"
echo "#     ControlPersist yes"
echo "#     StrictHostKeyChecking no"
echo "# "
echo "# ...it will make SSH connections persistent which should speed up Docker commands."
echo "# "

echo "# Done!"



