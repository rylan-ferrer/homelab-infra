resource "proxmox_virtual_environment_vm" "control_plane" {
  count     = 3
  name      = "k3s-cp-${count.index + 1}"
  node_name = local.control_plane_nodes[count.index]

clone {
    vm_id     = proxmox_virtual_environment_vm.ubuntu_template[local.control_plane_nodes[count.index]].vm_id
    node_name = local.control_plane_nodes[count.index]
  }

  lifecycle {
    ignore_changes = [clone]
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  initialization {
    vendor_data_file_id = proxmox_virtual_environment_file.qemu_agent_config[local.control_plane_nodes[count.index]].id
  }
}