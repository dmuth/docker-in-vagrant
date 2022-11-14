#!/bin/bash
#
# Set up our Vagrant instance.
#

# Errors are fatal
set -e 

apt update

apt install -y docker.io docker-compose

adduser vagrant docker && RETVAL=$? || RETVAL=$?
if test ${RETVAL} -eq 1
then
    echo "# User vagrant already in group docker, skipping..."

elif test ${RETVAL} -ne 0
then
    exit ${RETVAL}

fi

echo "MaxStartups 100:30:100" > /etc/ssh/sshd_config.d/max_startups.conf
echo "MaxSessions 100" >> /etc/ssh/sshd_config.d/max_startups.conf

sshd -T |grep -i maxstartups

systemctl restart sshd

