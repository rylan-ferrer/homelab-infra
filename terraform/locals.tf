locals {
  control_plane_nodes = ["node1", "node2", "node3"]
  worker_nodes         = ["node1", "node2", "node3", "node4"]

  control_plane_ips = var.control_plane_ips
  worker_ips        = var.worker_ips

  gateway = var.gateway_ip
  dns_servers = var.dns_ip
}