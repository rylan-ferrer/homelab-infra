resource "proxmox_virtual_environment_file" "qemu_agent_config" {
  for_each = toset(concat(local.control_plane_nodes, local.worker_nodes))

  content_type = "snippets"
  datastore_id = "local"
  node_name    = each.value

  source_raw {
    data = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - qemu-guest-agent
      runcmd:
        - systemctl enable --now qemu-guest-agent
    EOF
    file_name = "qemu-agent-config.yaml"
  }
}