# Proxmox Terraform

This configuration clones:

- `FS01` from a generalized Windows Server template
- `WEB01` from an Ubuntu Cloud-Init template
- `WAZUH01` from the same Ubuntu Cloud-Init template

It does **not** manage `DC01`, `SYNC01`, or `ADMIN01`. Keep those identity-critical VMs manually controlled in the first automation phase.

## Before you run Terraform

1. Create a generalized Windows template. It must not be your domain controller and must have been Sysprepped before conversion.
2. Create an Ubuntu Server Cloud-Init template with the QEMU Guest Agent installed and running.
3. Create a Proxmox API token.
4. Note your Proxmox endpoint, node name, storage name, bridge name, and both template VM IDs.
5. Ensure your local SSH agent has a key authorized on the Proxmox host, if the provider needs SSH for clone operations.

## Configure locally

```bash
cd terraform/proxmox
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values. It is ignored by Git; never commit the API token.

## First run

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

Read the plan. It should show only three new VMs: `FS01`, `WEB01`, and `WAZUH01`. When it looks correct:

```bash
terraform apply
```
