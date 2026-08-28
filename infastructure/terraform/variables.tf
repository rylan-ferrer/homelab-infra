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

variable "template_datastore_id" {
  description = "Where template base disks live - stays local per-node, not moved to shared storage"
  type        = string
  default     = "local-lvm"
}

variable "vm_datastore_id" {
  default = "local-lvm"
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

variable "gateway_ip" {
  description = "Router gatway IP" 
  type        = string
  sensitive   = true      
}

variable "dns_ip" {
  description = "IP for DNS resolution"
  type        = list(string)
  sensitive   = true      
}


variable "control_plane_ips" {
  description = "IPs for control plane VMs"
  type        = list(string)
  sensitive   = true      
}


variable "worker_ips" {
  description = "IPs for worker VMs"
  type        = list(string)
  sensitive   = true      
}
