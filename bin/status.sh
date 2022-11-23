#!/bin/bash
#
# Stop our Vagrant instance
#

# Fail on error 
set -e

# Change to our script's parent directory
pushd $(dirname $0)/..  > /dev/null

echo "# Checking status of VM..."
vagrant status
echo "# Done!"

