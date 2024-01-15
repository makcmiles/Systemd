# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
    :otuslinux => {
        :box_name => "generic/centos8s",
        :ip_addr => '192.168.56.101',
        :cpus => 2,
        :memory => 2024,  
    },
}

Vagrant.configure("2") do |config|
    MACHINES.each do |boxname, boxconfig|
      config.vm.synced_folder ".", "/vagrant", disabled: true
      config.vm.define boxname do |box|
        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s
        box.vm.network "private_network", ip: boxconfig[:ip_addr]
        box.vm.provider "virtualbox" do |v|
          v.memory = boxconfig[:memory]
          v.cpus = boxconfig[:cpus]
        end
        box.vm.provision "shell", path: "script.sh"
      end
    end
end