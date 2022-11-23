#!/bin/bash
#
# Stop our Vagrant instance
#

# Fail on error 
set -e

# Change to our script's parent directory
pushd $(dirname $0)/..  > /dev/null

echo "# SSHing into Docker VM..."
vagrant ssh
echo "# Done!"

