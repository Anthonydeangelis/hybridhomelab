# Architecture Decisions

I kept the design close to a small business environment, but made a few deliberate cuts to keep the lab affordable and safely contained.

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
| `KALI01` uses an internal-only Proxmox bridge | Keeps attacker simulation off the normal network while allowing a narrowly scoped FS01 SMB validation path. |

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

## Current validation status

The standalone Azure Terraform workload and the first `KALI01` validation are complete. Kali is restricted to an internal-only bridge and uses disposable accounts to create controlled failed SMB logons on FS01. The test is documented with a lab-only scope, cleanup guidance, and Wazuh correlation evidence in the [KALI01 validation runbook](kali-validation-runbook.md).
