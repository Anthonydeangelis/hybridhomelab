# Azure web workload evidence

These are the reviewed screenshots used in the Azure section of the main README:

| File | Evidence captured | Redaction reminder |
| --- | --- | --- |
| `01-terraform-apply-complete.png` | Terraform apply completed with ten resources added | No secrets shown. |
| `02-azure-resource-inventory.png` | Azure resource inventory for the deployed workload | Subscription details are not shown. |
| `05-key-vault-secrets-user-role.png` | VM identity assigned `Key Vault Secrets User` | Shows only the relevant principal. |
| `07-public-dns-resolution.png` | DNS resolution of the Azure public hostname | Public IP is intentionally visible. |
| `08-certbot-https-success.png` | Certbot successfully deployed the HTTPS certificate | No email address shown. |
| `10-key-vault-read-200.png` | Managed-identity request to Key Vault returned `200` | Token value is not shown. |
| `11-admin-page-unauthenticated.png` | `/admin/` returned `401` and a Basic Authentication challenge | No credentials shown. |
| `12-admin-page-authenticated.png` | Correct credentials loaded the protected admin page | No password is shown. |

All documented Azure validation steps have supporting evidence. Secret values, hashes, and tokens remain excluded from this folder.
