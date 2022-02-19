source "qemu" "example" {
  iso_url          = "https://mirrors.ocf.berkeley.edu/centos-stream/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-20220216.1-x86_64-boot.iso"
  iso_checksum     = "f11b2511eb3870100fd42a921a49d5ccca86fe510855e4774d70dfe6d10728be"
  output_directory = "output_centos"
  vm_name          = "centos_vm_test"

  disk_size = "5000M"
  memory    = 4096

  ssh_username = "root"
  ssh_password = "centoscentos"

  # if running qemu on a headless server, qemu will fail unless this is specified. 
  headless = "true"

  # this is helpful for being able to VNC into the packer'd VM if on headless server
  vnc_bind_address = "0.0.0.0"


  format      = "qcow2"
  accelerator = "kvm"


  ssh_timeout            = "30m"
  ssh_handshake_attempts = "20"

  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "3s"
  shutdown_command = "echo packer | sudo -S shutdown -P now"

  # Boot:
  #  0. gets into text mode interface
  #  1. normal boot options
  #  2. autoinstall options
  #  3. initiates boot sequence
  boot_command = [
    "<tab>",
    "text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<wait><enter>"
  ]


  # instead of specifying an http_directory, files are created on the fly using the http_content block.
  http_content = {
    "/ks.cfg" = <<EOF
#version=RHEL9
# Use graphical install
graphical

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

%packages
@^server-product-environment

%end

# Run the Setup Agent on first boot
firstboot --enable

# Generated using Blivet version 3.4.0
ignoredisk --only-use=sda
autopart
# Partition clearing information
clearpart --none --initlabel

# System timezone
timezone America/New_York --utc

# Root password
rootpw --iscrypted $6$F8dfcx4.H/2jNMSl$jUSGKy3ywHwnD98lzGZ6XTiv9x87qYavB9a0AdNunxammyQZJWP4q5KDw6M69OopYWf7vxzS4MU0/JDGSCcn10

EOF

  }
}

build {
  sources = ["source.qemu.example"]
}
