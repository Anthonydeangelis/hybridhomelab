resource "proxmox_virtual_environment_vm" "fs01" {
  name      = "FS01"
  node_name = var.node_name
  vm_id     = var.fs01_vmid

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 80
  }

  clone {
    vm_id        = var.windows_template_id
    full         = true
    datastore_id = var.datastore_id
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = var.bridge
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_servers" {
  for_each  = var.ubuntu_servers
  name      = each.key
  node_name = var.node_name
  vm_id     = each.value.vmid

  clone {
    vm_id        = var.ubuntu_template_id
    full         = true
    datastore_id = var.datastore_id
  }

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory_mb
  }

  network_device {
    bridge = var.bridge
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = each.value.disk_gb
  }

  initialization {
    datastore_id = var.datastore_id

    ip_config {
      ipv4 {
        address = each.value.address
      }
    }

    user_account {
      username = var.linux_username
      keys     = [trimspace(var.ssh_public_key)]
    }
  }
}
