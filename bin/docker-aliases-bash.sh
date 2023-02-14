#
# This file is meant to be included from .bashrc, and sets aliases for Docker.
#

DIR=$(realpath ${BASH_SOURCE})
DIR=$(dirname ${DIR})


alias docker-status="${DIR}/status.sh"
alias docker-check-time-offset="echo \"System Time: \$(date -u +%Y-%m-%dT%H:%M:%SZ)\"; echo \"    VM Time: \$(curl -s localhost:1404/time)\"; "
alias docker-start="${DIR}/start.sh"
alias docker-stop="${DIR}/stop.sh"
alias docker-restart="${DIR}/restart.sh"
alias docker-destroy="${DIR}/destroy.sh"
alias docker-ssh="${DIR}/ssh.sh"
alias docker-images-save="${DIR}/docker-images-save.sh"
alias docker-images-load="${DIR}/docker-images-load.sh"
alias docker-images-list="${DIR}/docker-images-list.sh"


alias docker-aliases="alias | egrep \"^alias docker-\""


