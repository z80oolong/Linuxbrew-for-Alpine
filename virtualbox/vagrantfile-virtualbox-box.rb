Vagrant.configure("2") do |config|
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end
  config.ssh.insert_key = false
  config.vm.synced_folder "./", "/vagrant"
  config.vm.base_mac = "0800279E9EE5"
end
