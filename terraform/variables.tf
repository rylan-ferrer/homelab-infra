variable "proxmox_node_name" {
  description = "The name of your Proxmox node, as shown in the Proxmox web UI sidebar"
  type        = string
  default     = "node3"
}

variable "image_datastore_id" {
  description = "Where cloud images get stored - check Datacenter > Storage in the web UI"
  type        = string
  default     = "local"
}

variable "vm_datastore_id" {
  description = "Where VM disks get stored - check Datacenter > Storage in the web UI"
  type        = string
  default     = "local-lvm"
}

variable "proxmox_api_token" {
    description = "Proxmox API Token"
    type = string
    sensitive = true
}

variable "proxmox_ssh_password" {
  description = "Root password for SSH access to the Proxmox node (used for disk import operations)"
  type        = string
  sensitive   = true
}

variable "proxmox_endpoint" {
    description = "Node3 url"
    type = string
}