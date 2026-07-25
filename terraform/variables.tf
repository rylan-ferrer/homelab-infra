variable "proxmox_node_name" {
  description = "The name of your Proxmox node, as shown in the Proxmox web UI sidebar"
  type        = string
  default     = "Node3"
}

variable "datastore_id" {
  description = "Where VM disks get stored - check Datacenter > Storage in the web UI"
  type        = string
  default     = "local-lvm"
}