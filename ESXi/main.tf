#########################################
#  ESXI Provider host/login details
#########################################
#
#   Use of variables here to hide/move the variables to a separate file
#
provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

#########################################
#  ESXI Guest resource
#########################################
resource "esxi_guest" "splunk" {
  guest_name = "PurpleLab-Splunk"
  disk_store = "RAID0-SSD-SATA"
  guestos    = "ubuntu-64"

  boot_disk_type = "thin"
  boot_disk_size = "35"

  memsize            = "4096"
  numvcpus           = "2"
  resource_pool_name = "/"
  power              = "on"
  clone_from_vm = "Ubuntu2004"

    provisioner "remote-exec" {
    inline = [
      "sudo ifconfig eth1 up || echo 'eth1 up'"
    ]

    connection {
      host        = self.ip_address
      type        = "ssh"
      user        = "vagrant"
      password    = "vagrant"
    }
  }
  # This is the network that bridges your host machine with the ESXi VM
  network_interfaces {
    virtual_network = var.vm_network
    nic_type        = "e1000"
  }
  network_interfaces {
    virtual_network = var.lab_network
    nic_type        = "e1000"
  }
  guest_startup_timeout  = 45
  guest_shutdown_timeout = 30
}

resource "esxi_guest" "dc" {
  guest_name = "PurpleLab-DC"
  disk_store = "RAID0-SSD-SATA"
  guestos    = "windows9srv-64"

  boot_disk_type = "thin"
  boot_disk_size = "35"

  memsize            = "4096"
  numvcpus           = "2"
  resource_pool_name = "/"
  power              = "on"
  clone_from_vm = "WindowsServer2016"
  network_interfaces {
    virtual_network = var.vm_network
    nic_type        = "e1000"
  }
  network_interfaces {
    virtual_network = var.lab_network
    nic_type        = "e1000"
  }
  guest_startup_timeout  = 45
  guest_shutdown_timeout = 30
}

resource "esxi_guest" "win10" {
  guest_name = "PurpleLab-Win10"
  disk_store = "RAID0-SSD-SATA"
  guestos    = "windows9-64"

  boot_disk_type = "thin"
  boot_disk_size = "35"

  memsize            = "2048"
  numvcpus           = "2"
  resource_pool_name = "/"
  power              = "on"
  clone_from_vm = "Windows10"
  network_interfaces {
    virtual_network = var.vm_network
    nic_type        = "e1000"
  }
  network_interfaces {
    virtual_network = var.lab_network
    nic_type        = "e1000"
  }
  guest_startup_timeout  = 45
  guest_shutdown_timeout = 30
}
