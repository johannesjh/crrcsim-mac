# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrant file for building a CRRCSim binary and app bundle for Mac OS.


unless Vagrant.has_plugin?("vagrant-scp")
  raise 'Please run `vagrant plugin install vagrant-scp` to use this Vagrantfile.'
end

Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox" do |vb|
    # vb.gui = true
    vb.memory = 1024
  end

  config.vm.define "darwin" do |b|
    b.vm.box = "jhcook/osx-elcapitan-10.11" # or jhcook/macos-sierra for a newer mac os
    b.vm.provision "Base Installation", type: "shell", privileged: false, path: "scripts/base-installation.sh"
    b.vm.provision "Build Process", type: "shell", privileged: false, run: "always", path: "scripts/build-process.sh"
  end

end
