locals {
  control_plane_nodes = ["node1", "node2", "node3"]
  worker_nodes         = ["node1", "node2", "node3", "node4"]

  control_plane_ips = ["192.168.0.204", "192.168.0.205", "192.168.0.206"]
  worker_ips        = ["192.168.0.207", "192.168.0.208", "192.168.0.209", "192.168.0.210"]

  gateway = "192.168.0.1"
  dns_servers = ["1.1.1.1", "1.0.0.1"]
}