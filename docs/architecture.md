# Architecture Decisions

This document records the design choices behind the hybrid identity and security homelab. The goal is to show a realistic small-enterprise pattern while keeping the environment safe, affordable, and easy to explain.

## Active design

| Decision | Rationale |
| --- | --- |
| Proxmox hosts the on-premises lab | Keeps identity, file services, monitoring, and internal applications on a private network that the lab owner controls. |
| `DC01` is the AD DS and DNS authority | Provides a practical foundation for identities, groups, DNS, and Windows access control. |
| `ADMIN01` is used for routine AD administration | Separates management work from the domain controller and reflects standard administrative practice. |
| `SYNC01` runs Microsoft Entra Connect Sync | Demonstrates hybrid identity by synchronizing only selected lab identities to Microsoft Entra ID. |
| `WEB01` remains an internal application | Avoids exposing the Linux web server directly to the internet. |
| Entra Application Proxy publishes `WEB01` | Provides identity-aware, outbound-connector access for approved remote users. |
| Conditional Access protects the published app | Demonstrates cloud-side access policy and MFA for the assigned application users. |
| Wazuh centralizes monitoring | Provides a single place to observe Windows and Linux events and validate tuned detections. |

## Network and identity boundary

Microsoft Entra Connect Sync is an identity synchronization component. It does **not** create a Site-to-Site VPN, extend the home network to Azure, or allow Active Directory replication across the internet.

The Azure Terraform workload is intentionally standalone. It demonstrates repeatable cloud infrastructure and security controls without claiming a private network path to the Proxmox environment.

```text
On-premises lab                    Microsoft Entra ID                 Standalone Azure workload
----------------                   ------------------                 -------------------------
DC01 / FS01 / WEB01                Synced lab identities              Terraform-managed VNet
        |                                   |                           NSG / Linux VM / Key Vault
        |        Entra Connect Sync         |                                    |
SYNC01  ---------------------------->       |             No private route or AD replication
                                            |
Remote user --> Entra sign-in --> App Proxy connector --> internal WEB01
```

## Explicit non-goals

The following are intentionally outside the active design:

- Site-to-Site VPN between Azure and the home lab
- Azure domain controllers or RODCs
- Direct inbound internet exposure of `WEB01`
- Public exposure of AD, SMB, RDP, Proxmox, Wazuh, or management interfaces
- Unscoped testing from `KALI01`

## Next planned addition

The standalone Azure Terraform workload is complete and documented with redacted evidence. `KALI01` remains the next planned phase and will be added only with documented network isolation, a lab-only scope, clear cleanup steps, and redacted evidence.
