# Operations Runbook

This runbook lists quick health checks for the lab. Commands should be run only on the relevant lab system and screenshots should be redacted before publishing.

## DC01 — Active Directory and DNS

Purpose: confirm the domain controller is healthy and clients can resolve AD names.

```powershell
dcdiag
repadmin /replsummary
Resolve-DnsName corp.local
Get-ADDomain
```

Expected result:

- `corp.local` resolves through `DC01`.
- AD DS and DNS services are running.
- No unexpected replication partner is required because this lab has one active DC.

## SYNC01 — Microsoft Entra Connect Sync

Purpose: confirm hybrid identity synchronization is healthy and scoped.

```powershell
Get-Service ADSync
Start-ADSyncSyncCycle -PolicyType Delta
```

Expected result:

- `ADSync` is running.
- Only the dedicated lab sync OU is in scope.
- Disposable lab users appear in Entra ID.

## Application publishing — WEB01 access

Purpose: confirm remote users can access the internal app without direct inbound exposure.

Checks:

- Connector status is healthy in Entra.
- Enterprise Application is assigned only to lab users/groups.
- Remote browser access requires Entra sign-in.
- `WEB01` is reachable internally from the connector host.

## FS01 — File services

Purpose: confirm SMB shares and AGDLP permissions work as designed.

```powershell
Get-SmbShare
Get-SmbShareAccess -Name <ShareName>
```

Expected result:

- Share access is assigned to domain local groups.
- Users receive access through global group membership.
- Individual users are not directly assigned NTFS permissions.

## WEB01 — Linux web service

Purpose: confirm the internal app is available.

```bash
systemctl status nginx --no-pager
curl -I http://localhost
```

Expected result:

- Nginx is running.
- The local web service returns an HTTP response.

## WAZUH01 — Monitoring

Purpose: confirm manager, dashboard, indexer, and agents are healthy.

```bash
sudo /var/ossec/bin/wazuh-control status
sudo systemctl status wazuh-manager wazuh-dashboard wazuh-indexer --no-pager
```

Expected result:

- Wazuh manager services are running.
- Dashboard is private to the lab.
- Agents for `DC01`, `SYNC01`, `FS01`, `WEB01`, and `ADMIN01` check in.

## Safety reminders

- Do not publish secrets, tenant IDs, public URLs, recovery keys, private IP maps, or unredacted screenshots.
- Do not expose AD, SMB, RDP, Wazuh, or management ports to the internet.
- Run validation scenarios only against lab-owned systems and disposable accounts.
