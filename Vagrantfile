Vagrant.configure("2") do |config|

  # The base PMBox
  config.vm.box = "ubuntu/trusty64"

  # Port 80 goes to 8080
  config.vm.network :forwarded_port, guest: 80, host: 8080

  # We use the private network; but feel free to change it to public
  config.vm.network :private_network, ip: "23.10.86.26"

  # config.vm.network :public_network

  # Mount the plugins folder to make development easier
  config.vm.synced_folder "./plugins", "/opt/plugins/"

  # Using Puppet to provision our PMBox
  config.vm.provision :puppet

end
