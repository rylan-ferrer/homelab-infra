# Will use this for VM resource definitions

resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name      = "ubuntu-2404-template"
  node_name = var.proxmox_node_name
  template  = true  # marks this as a template - never boots directly, only gets cloned
  started   = false # templates shouldn't be running

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = var.vm_datastore_id
    file_id      = proxmox_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.qemu_agent_config["node3"].id

    user_account {
      username = "ubuntu"
    keys = [trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))]
    }
  }
}