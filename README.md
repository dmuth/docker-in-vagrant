


ssh-add .vagrant/machines/default/virtualbox/private_key
ssh -o StrictHostKeyChecking=no -p 2222 vagrant@127.0.0.1 whoami




`WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`

sed -i -e 366d  ~/.ssh/known_hosts 
#[127.0.0.1]:2222


export DOCKER_HOST=ssh://vagrant@127.0.0.1:2222

Host 127.0.0.1
    ControlMaster auto
    ControlPath ~/.ssh/master-%r@%h:%p

