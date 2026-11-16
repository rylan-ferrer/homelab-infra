output "control_plane_ips" {
  description = "IP addresses of the k3s control-plane VMs"
  value       = [for idx, vm in proxmox_virtual_environment_vm.control_plane : try(vm.ipv4_addresses[1][0], local.control_plane_ips[idx])]
  sensitive   = true
}

output "worker_ips" {
  description = "IP addresses of the k3s worker VMs"
  value       = [for idx, vm in proxmox_virtual_environment_vm.worker : try(vm.ipv4_addresses[1][0], local.worker_ips[idx])]
  sensitive   = true
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../../configuration/ansible/inventory/hosts.yml"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    control_plane_ips = [for idx, vm in proxmox_virtual_environment_vm.control_plane : try(vm.ipv4_addresses[1][0], local.control_plane_ips[idx])]
    worker_ips        = [for idx, vm in proxmox_virtual_environment_vm.worker : try(vm.ipv4_addresses[1][0], local.worker_ips[idx])]
  })
}