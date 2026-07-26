output "control_plane_ips" {
  description = "IP addresses of the k3s control-plane VMs"
  value       = [for vm in proxmox_virtual_environment_vm.control_plane : try(vm.ipv4_addresses[1][0], "pending")]
}

output "worker_ips" {
  description = "IP addresses of the k3s worker VMs"
  value       = [for vm in proxmox_virtual_environment_vm.worker : try(vm.ipv4_addresses[1][0], "pending")]
}