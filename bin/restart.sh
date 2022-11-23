#!/bin/bash
#
# Destroy our Vagrant instance
#

# Fail on error 
set -e

# Change to our script's parent directory
pushd $(dirname $0)/..  > /dev/null

echo "# Restarting VM..."
vagrant reload
echo "# Done!"

