resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  for_each = toset(concat(local.control_plane_nodes, local.worker_nodes))

  name      = "ubuntu-2404-template-${each.value}"
  node_name = each.value
  template  = true
  started   = false

  agent {
    enabled = false
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = var.template_datastore_id
    file_id      = proxmox_download_file.ubuntu_cloud_image[each.value].id
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
    vendor_data_file_id = proxmox_virtual_environment_file.qemu_agent_config[each.value].id

    user_account {
      username = "ubuntu"
      keys     = [trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))]
    }
  }
}