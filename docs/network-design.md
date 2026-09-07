# Network Design

## Addressing model

The existing home network uses private `192.168.x.x` addressing. Reserve or statically assign unique addresses for lab VMs through the home router or documented local configuration. Do not publish the exact values in this repository.

| Segment | Intended members | Enforcement requirement |
| --- | --- | --- |
| Core services | `DC01`, `FS01`, `WEB01`, `SYNC01`, `ADMIN01` | Private home LAN or dedicated Proxmox bridge |
| Monitoring | `WAZUH01` | Private only; dashboard must not be publicly exposed |
| Test segment | `KALI01` and the second `FS01` adapter | Internal-only Proxmox bridge `vmbr1`; no physical bridge port or default gateway; FS01 permits only Kali-to-SMB traffic |
| Azure VNet | `10.100.0.0/16` | Terraform-managed; separate from the home network |
| Azure web subnet | `10.100.2.0/24` | Azure web VM; no route to the home network |
| App publishing | Entra Application Proxy connector | Outbound-only access to Microsoft cloud services; internal reachability to `WEB01` |

## DNS

Domain clients use `DC01` for `corp.local` resolution. Public resolvers may be used only as forwarders, not as the configured primary DNS server on a domain client.

## KALI01 test-segment implementation

The completed Kali validation uses `172.30.30.0/24` only inside Proxmox:

```text
KALI01  172.30.30.20/24  -> vmbr1 -> 172.30.30.10/24  FS01 secondary adapter
```

`vmbr1` is a virtual Layer-2 switch rather than a routed network. It has no physical uplink, and Kali has no gateway or DNS server on this interface. `FS01` retains its separate normal adapter for AD and Wazuh communications; Windows Defender Firewall on its test adapter permits TCP 445 only from the Kali address. Kali's normal-network adapter is removed after setup, so the attacker-simulation VM cannot reach the normal `192.168.x.x` segment.

See the [KALI01 validation runbook](kali-validation-runbook.md) for the controlled SMB test and evidence.

## Azure NSG intent

| Direction | Source | Destination / port | Purpose |
| --- | --- | --- | --- |
| Inbound | administrative CIDR | TCP 22 | SSH administration |
| Inbound | Internet | TCP 80, 443 | Public web service |
| Inbound | Any | all other ports | Deny by default |

No rule opens AD, SMB, RDP, Wazuh, database, or management services from the Internet.

## Remote access to internal web app

Remote/cloud users access the internal `WEB01` application through Entra application publishing, not through open inbound firewall rules.

```text
Remote user
  -> Microsoft Entra sign-in
  -> Published enterprise application
  -> Internal Application Proxy connector
  -> WEB01 private web service
```

This keeps the app access path identity-aware and avoids exposing `WEB01`, Wazuh, SMB, RDP, or domain services directly to the internet.
