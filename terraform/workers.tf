resource "proxmox_virtual_environment_vm" "worker" {
  count     = 4
  name      = "k3s-worker-${count.index + 1}"
  node_name = ["node1", "node2", "node3", "node4"][count.index]

  clone {
    vm_id        = 100
    node_name    = "node3"
    datastore_id = var.vm_datastore_id
  }

  lifecycle { 
    ignore_changes = [clone]
  }
  cpu {
    cores = 4
  }

  memory {
    dedicated = [10240, 10240, 10240, 14336][count.index]
  }
}