#!/bin/bash
#
# Set up our Vagrant instance.
#

# Errors are fatal
set -e 

#
# Grab our arguments
#
SKIP_APT=$1
SKIP_DOCKER=$2
SKIP_SSH=$3
SKIP_TIME=$4
#echo "DEBUG: $@" # Debugging
#echo "DEBUG: SKIP_APT=${SKIP_APT}, SKIP_DOCKER=${SKIP_DOCKER}, SKIP_SSH=${SKIP_SSH}, SKIP_TIME=${SKIP_TIME}" # Debugging
#exit;

if test ! "${SKIP_APT}" != "0"
then

    apt update

    echo "# "
    echo "# Downloading packages into local cache..."
    echo "# "
    apt install -dy docker.io docker-compose
    apt install -dy swapspace net-tools pv
    apt install -dy python3-pip

    echo "# "
    echo "# Installing packages from cache..."
    echo "# "
    apt install -y docker.io docker-compose
    apt install -y swapspace net-tools pv
    apt install -y python3-pip

fi


if test ! "${SKIP_DOCKER}" != "0" 
then

    adduser vagrant docker && RETVAL=$? || RETVAL=$?
    if test ${RETVAL} -eq 1
    then
        echo "# User vagrant already in group docker, skipping..."

    elif test ${RETVAL} -ne 0
    then
        exit ${RETVAL}

    fi

    echo "# Loading cached Docker images..."
    /vagrant/bin/docker-load-images.sh

fi


if test ! "${SKIP_SSH}" != "0" 
then

    echo "# Configuring sshd..."
    echo "MaxStartups 100:30:100" > /etc/ssh/sshd_config.d/max_startups.conf
    echo "MaxSessions 100" >> /etc/ssh/sshd_config.d/max_startups.conf
    #sshd -T |grep -i maxstartups # Debugging

    echo "# Restarting sshd..."
    systemctl restart sshd

fi


if test ! "${SKIP_TIME}" != "0" 
then

    echo "# Installing web service..."
    pip3 install web.py

    cd /etc/systemd/system
    ln -sf /vagrant/bin/webtime.service .
    systemctl daemon-reload
    systemctl enable webtime
    systemctl start webtime
    #systemctl status webtime # Debugging

fi


echo "# Done!"


