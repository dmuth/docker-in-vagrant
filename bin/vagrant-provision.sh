#!/bin/bash
#
# Set up our Vagrant instance.
#

# Errors are fatal
set -e 

apt update

echo "# "
echo "# Downloading packages into local cache..."
echo "# "
apt install -dy docker.io docker-compose
apt install -dy swapspace net-tools pv

echo "# "
echo "# Installing packages from cache..."
echo "# "
apt install -y docker.io docker-compose
apt install -y swapspace net-tools pv

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

echo "# Configuring sshd..."
echo "MaxStartups 100:30:100" > /etc/ssh/sshd_config.d/max_startups.conf
echo "MaxSessions 100" >> /etc/ssh/sshd_config.d/max_startups.conf
#sshd -T |grep -i maxstartups # Debugging

echo "# Restarting sshd..."
systemctl restart sshd

echo "# Done!"


