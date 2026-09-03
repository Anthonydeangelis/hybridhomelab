# Architecture Diagram

`hybrid-enterprise-homelab.svg` is the editable source diagram used in the README. It shows the active no-VPN architecture:

- `SYNC01` synchronizes selected lab identities to Microsoft Entra ID.
- The private Application Proxy connector reaches internal `WEB01` through an outbound-only connection.
- The Azure web workload is standalone; its web VM uses Key Vault for the protected admin-page password hash.
- No private Azure-to-home network path, Azure domain controller, or Active Directory replication path exists.
