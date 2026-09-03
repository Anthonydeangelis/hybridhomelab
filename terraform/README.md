# Terraform Azure Workload

This Terraform configuration creates a standalone Azure web workload: resource group, VNet, web subnet, NSG, public IP, Ubuntu VM, Storage Account, and Key Vault. The VM has a system-assigned managed identity with the least-privilege `Key Vault Secrets User` role on this workload's Key Vault. It does **not** create a VPN, Azure domain controller, or a route to the home lab.

The Azure workload is separate from Entra Application Proxy publishing for the private, Proxmox-hosted `WEB01` app. Terraform demonstrates cloud infrastructure-as-code; Entra Application Proxy demonstrates identity-aware access to an internal application.

## Deploy the infrastructure

No Azure Storage Account or Key Vault is required before the first deployment. Set globally unique names for each in `terraform.tfvars`; Terraform creates both workload resources during `terraform apply`. Terraform enables Key Vault RBAC and grants only the VM's managed identity permission to read secrets. No secret values are created or stored in Terraform state by this configuration.

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Review the plan before `terraform apply`, and destroy resources when the lab demo is complete. State and tfvars files are ignored by Git.

## Completed Azure web administration feature

The deployed Azure web VM is published at `https://hybridhomelabweb.eastus2.cloudapp.azure.com`. Nginx serves the HTTPS site and protects `/admin/` with HTTP Basic Authentication. The authentication file uses a bcrypt password hash sourced from Azure Key Vault; no plaintext administrator password is stored in Terraform, Git, or the Nginx configuration.

```text
Key Vault secret (bcrypt htpasswd entry)
        ↓  Azure VM system-assigned managed identity
/etc/nginx/.htpasswd on the Azure VM
        ↓
Nginx validates each /admin/ request locally
```

### HTTPS configuration commands used

The Azure Public IP was given the DNS label `hybridhomelabweb`, which resolves in the East US 2 region. Nginx and Certbot were installed on the Ubuntu VM, and Certbot requested the certificate and configured the HTTP-to-HTTPS redirect.

```bash
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx
sudo systemctl enable --now nginx

sudo certbot --nginx \
  -d hybridhomelabweb.eastus2.cloudapp.azure.com \
  --redirect \
  -m YOUR_REAL_EMAIL \
  --agree-tos \
  --no-eff-email
```

The email address is intentionally not recorded in this repository. Port 22 remains restricted through `admin_cidr`; the public web endpoint uses ports 80 and 443.

### Key Vault secret and access validation

The Key Vault is `anthomelabkv1` and the secret name is `web-admin-password`. Its value is a complete bcrypt `htpasswd` entry, not a plaintext password:

```text
labadmin:$2y$...bcrypt-hash...
```

The `labadmin` prefix is the Nginx username. The hash was generated interactively with:

```bash
htpasswd -nB labadmin
```

The VM's system-assigned managed identity was then tested against Key Vault. This command does not display the secret; it prints only an HTTP status code. A result of `200` verified that the VM can read the secret through its `Key Vault Secrets User` role.

```bash
TOKEN=$(curl --noproxy '*' -sS -f \
  -H "Metadata: true" \
  "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=https%3A%2F%2Fvault.azure.net" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')

curl --noproxy '*' -sS -o /dev/null -w "%{http_code}\n" \
  -H "Authorization: Bearer ${TOKEN}" \
  "https://anthomelabkv1.vault.azure.net/secrets/web-admin-password?api-version=7.4"
```

### Nginx admin-page configuration commands used

The password-hash secret was retrieved manually and written to Nginx's local authentication file with restricted permissions. This command does not print the hash.

```bash
TOKEN=$(curl --noproxy '*' -sS -f \
  -H "Metadata: true" \
  "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=https%3A%2F%2Fvault.azure.net" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')

curl --noproxy '*' -sS -f \
  -H "Authorization: Bearer ${TOKEN}" \
  "https://anthomelabkv1.vault.azure.net/secrets/web-admin-password?api-version=7.4" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["value"])' \
  > /etc/nginx/.htpasswd

chown root:www-data /etc/nginx/.htpasswd
chmod 640 /etc/nginx/.htpasswd
```

The following block was added inside the HTTPS Nginx `server` block:

```nginx
location = /admin {
    return 301 /admin/;
}

location /admin/ {
    auth_basic "Admin Only";
    auth_basic_user_file /etc/nginx/.htpasswd;

    root /var/www/html;
    index index.html;
    try_files $uri $uri/ =404;
}
```

Nginx configuration was tested and reloaded:

```bash
sudo nginx -t && sudo systemctl reload nginx
```

### Validation performed

```bash
curl -I https://hybridhomelabweb.eastus2.cloudapp.azure.com/admin/
```

An unauthenticated request returned `401 Unauthorized`. Opening the same URL in a browser prompted for `labadmin`; supplying the matching password loaded the protected admin page.

<details>
<summary>Azure evidence</summary>

- [Terraform apply: ten resources added](../evidence/azure/01-terraform-apply-complete.png)
- [Azure resource inventory](../evidence/azure/02-azure-resource-inventory.png)
- [Key Vault Secrets User role assignment](../evidence/azure/05-key-vault-secrets-user-role.png)
- [Public DNS resolution](../evidence/azure/07-public-dns-resolution.png)
- [Certbot HTTPS success](../evidence/azure/08-certbot-https-success.png)
- [Managed-identity Key Vault read validation: `200`](../evidence/azure/10-key-vault-read-200.png)
- [Unauthenticated `/admin/` response: `401`](../evidence/azure/11-admin-page-unauthenticated.png)
- [Authenticated `/admin/` page](../evidence/azure/12-admin-page-authenticated.png)

Secret values, hashes, and tokens remain excluded from evidence.

</details>

### Current implementation boundary

Nginx checks the local `/etc/nginx/.htpasswd` file for every `/admin/` request. It does **not** call Key Vault for every login. The Key Vault retrieval was performed manually during the build, so when the password is rotated in Key Vault, the retrieval commands above must be run again to refresh the local hash. An automated refresh timer is a possible future improvement, but it is intentionally not part of this implementation.
