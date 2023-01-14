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

echo "# "
echo "# Please add the following to \$HOME/.ssh/config in order to access this instance via Docker: "
echo "# "
echo "# Host 127.0.0.1"
echo "#     ControlMaster auto"
echo "#     ControlPath ~/.ssh/master-%r@%h:%p"
echo "#     ControlPersist yes"
echo "#     StrictHostKeyChecking no"
echo "#     UserKnownHostsFile /dev/null"
echo "#     IdentityFile $(pwd)/.vagrant/machines/default/virtualbox/private_key"
echo "#     IdentitiesOnly yes"
echo "# "
echo "# ...it will make SSH connections persistent which should speed up Docker commands."
echo "# "

echo "# "
echo "# Also consider adding these aliases to your .bashrc file to make management of this VM easier: "
echo "# "
echo "# alias docker-status='$(pwd)/bin/status.sh'"
echo "# alias docker-check-time-offset='date -u +%Y%m%dT%H%M%SZ; curl localhost:1404/time; date -u +%Y%m%dT%H%M%SZ'"
echo "# alias docker-start='$(pwd)/bin/start.sh'"
echo "# alias docker-stop='$(pwd)/bin/stop.sh'"
echo "# alias docker-restart='$(pwd)/bin/restart.sh'"
echo "# alias docker-destroy='$(pwd)/bin/destroy.sh'"
echo "# alias docker-ssh='$(pwd)/bin/ssh.sh'"
echo "# "

echo "# Done!"



