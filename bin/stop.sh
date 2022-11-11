#!/bin/bash
#
# Stop our Vagrant instance
#

# Fail on error 
set -e

# Change to our script's parent directory
pushd $(dirname $0)/..  > /dev/null

echo "# Stopping VM..."
vagrant halt
echo "# Done!"

