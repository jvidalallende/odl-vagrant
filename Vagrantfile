# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# This Vagrantfile only works with virtualbox
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Base box is Ubuntu 16.04 Xenial Xerus
  config.vm.box_url = "https://atlas.hashicorp.com/ubuntu/boxes/xenial64"
  config.vm.box = "ubuntu/xenial64"

  config.vm.provider :virtualbox do |vb|
    vb.name = "ODL-Vagrant"
    vb.customize ["modifyvm", :id, "--memory", "4096"]

    # This is needed to resize the disk (by default just 10G) to 50G
    # Note that this may not be the correct file name, it is tied to current
    # version of the box
    # Only do it the first time
    unless File.directory? "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}"
      vb.customize [
        "clonehd", "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ubuntu-xenial-16.04-cloudimg.vmdk",
                   "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ubuntu-xenial-16.04-cloudimg.vdi",
        "--format", "VDI"
      ]
      vb.customize [
        "modifyhd", "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ubuntu-xenial-16.04-cloudimg.vdi",
        "--resize", 50 * 1024
      ]
      vb.customize [
        "storageattach", :id,
        "--storagectl", "SCSI Controller",
        "--port", "0",
        "--device", "0",
        "--type", "hdd",
        "--nonrotational", "on",
        "--medium", "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ubuntu-xenial-16.04-cloudimg.vdi"
      ]
      if File.exists? "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ubuntu-xenial-16.04-cloudimg.vmdk"
        File.delete "#{ENV["HOME"]}/VirtualBox VMs/#{vb.name}/ubuntu-xenial-16.04-cloudimg.vmdk"
      end
    end
  end

  # Enable X forwarding through SSH
  config.ssh.forward_x11 = true

  # Copy local SSH key
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"
  config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "~/.ssh/id_rsa"

  # Provision VM. Use regular user, not root (passwordless sudo is available)
  config.vm.provision "shell", path: "bootstrap.bash", privileged: false

end
