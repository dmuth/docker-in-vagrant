# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/focal64" # 20.04.5 LTS

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = "4"
    end

    #
    # Load our filesystem mounts
    #
    require './vagrant-filesystem-mounts.rb'
    load_mounts(config)


    #
    # Forward our ports.  Feel free to add more as needed.
    #
    config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"
    config.vm.network "forwarded_port", guest: 8000, host: 8000, host_ip: "127.0.0.1"
    config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"

    config.vm.provision "shell", path: "bin/vagrant-provision.sh"

end


