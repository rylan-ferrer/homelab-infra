resource "proxmox_virtual_environment_vm" "worker" {
  count     = 4
  name      = "k3s-worker-${count.index + 1}"
  node_name = local.worker_nodes[count.index]

  clone {
    vm_id        = 100
    node_name    = "node3"
    datastore_id = var.vm_datastore_id
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = [10240, 10240, 10240, 14336][count.index]
  }

  initialization {
    vendor_data_file_id = proxmox_virtual_environment_file.qemu_agent_config[local.worker_nodes[count.index]].id
  }

  lifecycle {
    ignore_changes = [clone]
  }
}