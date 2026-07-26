resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = var.image_datastore_id # cloud images get stored here, separate from your VM disk storage
  node_name    = var.proxmox_node_name

  url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name = "noble-server-cloudimg-amd64.img" # renaming with .qcow2 tells Proxmox the image format
  overwrite = false
}
