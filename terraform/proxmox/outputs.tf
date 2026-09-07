output "fs01_name" {
  value = proxmox_virtual_environment_vm.fs01.name
}

output "ubuntu_vm_names" {
  value = { for name, vm in proxmox_virtual_environment_vm.ubuntu_servers : name => vm.name }
}
