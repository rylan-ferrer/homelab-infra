resource "proxmox_virtual_environment_vm" "control_plane" {
  count     = 3
  name      = "k3s-cp-${count.index + 1}"
  node_name = local.control_plane_nodes[count.index]

  clone {
    vm_id = 100
    node_name = "node3"
    datastore_id = var.vm_datastore_id
  }

  lifecycle { 
    ignore_changes = [clone]
  }
  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }
}