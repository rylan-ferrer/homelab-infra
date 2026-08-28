resource "proxmox_download_file" "ubuntu_cloud_image" {
  for_each = toset(concat(local.control_plane_nodes, local.worker_nodes))

  content_type = "iso"
  datastore_id = var.image_datastore_id
  node_name    = each.value

  url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name = "noble-server-cloudimg-amd64.img"
}