# homelab-infra
Repo to house my infrastructure for my homelab 


## Architecture Overview

```mermaid
flowchart TB
    subgraph Proxmox_VE["Proxmox VE Host"]
        direction TB
        SetupScripts["setup-scripts/<br>• proxmox-node-setup.sh<br>• pve-cpu-temp.sh"]

        subgraph VM_Infra["Terraform & Cloud-Init Provisioning"]
            direction LR
            CP_VM["Control-Plane VM(s)<br>(control-plane.tf)"]
            Worker_VM["Worker VM(s)<br>(workers.tf)"]
        end
    end

    subgraph K3s_Cluster["K3s Kubernetes Cluster"]
        direction TB

        subgraph Core_Services["Cluster Networking & Services"]
            KubeVIP["kube-vip<br>(VIP / HA)"]
            MetalLB["MetalLB<br>(LoadBalancer)"]
            CertManager["cert-manager<br>(Let's Encrypt Prod)"]
            NFS["NFS Provisioner<br>(Persistent Storage)"]
        end

        subgraph Workloads["Deployed Applications & Workloads"]
            AdGuard["AdGuard Home"]
            HA["Home Assistant"]
            Jellyfin["Jellyfin Media Server"]
            Minecraft["Minecraft Server"]
            subgraph Bambu_Stack["3D Printing Tools"]
                Bambuddy["Bambuddy"]
                BambuStudio["Bambu Studio"]
                OrcaSlicer["OrcaSlicer"]
            end
        end
    end

    Ansible["Ansible Automation<br>(k3s-install.yml)"] -->|Deploys & Configures| K3s_Cluster
    VM_Infra -->|Runs on| Proxmox_VE
    K3s_Cluster -->|Hosted within VMs| VM_Infra
    Core_Services -.->|Provides Services & Storage| Workloads
```
