Vagrant.configure("2") do |config|

  # The base PMBox
  config.vm.box = "pmbox"
  # PMBox url
  config.vm.box_url = "https://s3.amazonaws.com/ThePMBox/pm.box"

  # Port 80 goes to 8080
  config.vm.network :forwarded_port, guest: 80, host: 8080

  # config.vm.network :private_network, ip: "192.168.33.10"

  # We use the public network; but feel free to change it to private
  config.vm.network :public_network

  # Mount the plugins folder to make development easier
  config.vm.synced_folder "./plugins", "/opt/plugins/"

  # Using Puppet to provision our PMBox
  config.vm.provision :puppet

end
