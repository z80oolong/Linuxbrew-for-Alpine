Vagrant.configure("2") do |config|
  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus              = 1
    libvirt.memory            = 2048
    libvirt.machine_type      = "pc-q35-4.2"
    libvirt.disk_bus          = 'sata'
    libvirt.storage_pool_name = "default"
    libvirt.video_type        = "qxl"
    libvirt.graphics_type     = "spice"
  end
  config.ssh.insert_key = false
  config.vm.synced_folder "./", "/vagrant", type: "9p", disabled: false, \
                                            accessmode: "squash", owner: "1000"
end
