# Evidence

This folder contains screenshots from controlled tests in the homelab. They support the claims in the repository README and use lab-only identities.

## Folders

```text
evidence/
  ad/
  entra-connect/
  app-proxy/
  conditional-access/
  web01/
  wazuh/
  kali/
  azure/
```

## Current evidence

| Folder | What it shows |
| --- | --- |
| `ad/` | OU layout, AD services, and lab users |
| `entra-connect/` | Synchronized identities and the Application Proxy access group |
| `app-proxy/`, `conditional-access/` | Connector health, MFA, allowed access, and denied access |
| `web01/` | Internal Nginx page, HTTP response, and DNS |
| `wazuh/` | Active agents and custom detection results |
| `kali/` | Disposable accounts and the FS01 failed-logon correlation |
| `azure/` | Terraform deployment, HTTPS, Key Vault access, and protected admin access |

I reviewed the screenshots before committing them. Passwords, tokens, tenant and subscription IDs, private keys, and private management addresses are not included.
