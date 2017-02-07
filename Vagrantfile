# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Base box is Ubuntu 16.04 Xenial Xerus
  config.vm.box_url = "https://atlas.hashicorp.com/ubuntu/boxes/xenial64"
  config.vm.box = "ubuntu/xenial64"

  # Copy local SSH key
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/me.pub"
  # Provision VM. Use regular user, not root (passwordless sudo is available)
  config.vm.provision "shell", path: "bootstrap.sh", privileged: false
   
   config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
  end

end
