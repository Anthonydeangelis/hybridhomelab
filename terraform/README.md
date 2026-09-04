# Terraform Azure Workload

This configuration deploys the standalone Azure infrastructure for the project:

- Resource group, VNet, web subnet, network security group, and public IP.
- Ubuntu web VM with a system-assigned managed identity.
- Storage Account and Key Vault.
- A least-privilege `Key Vault Secrets User` assignment for the Azure web VM identity.

It does **not** create a VPN, Azure domain controller, or route to the private Proxmox lab. The Azure workload is intentionally independent from the Entra Application Proxy path used to publish the internal `WEB01` application.

## Deploy

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Set globally unique Storage Account and Key Vault names in the ignored `terraform.tfvars` file before applying. Review the plan before deployment and destroy the resource group when the lab demonstration is complete.

## Scope boundary

This folder covers infrastructure provisioning only. The public Nginx site, HTTPS certificate, Key Vault password-hash retrieval, and protected `/admin/` validation are documented with evidence in the [main project README](../README.md#9-azure-infrastructure-as-code-and-protected-web-administration).

Terraform state, local variable files, and secrets are ignored by Git.
