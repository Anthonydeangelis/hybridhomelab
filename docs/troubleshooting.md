# Troubleshooting Notes

These were the main problems I ran into while building and testing the lab.

## Name resolution

When a domain client could reach `DC01` by IP but not by name, the client was not using AD DNS. I pointed its primary DNS setting to `DC01`, then checked both records:

```powershell
nslookup WIN-DC01
nslookup WIN-DC01.corp.local
```

Domain clients use public resolvers through DNS forwarders on `DC01`, not directly on their adapters.

## Domain join failures

The domain join depended on DNS and time being correct first. I checked `Resolve-DnsName corp.local`, compared the client clock with `DC01`, and only then retried `Add-Computer`.

## Entra Connect scope

If unexpected identities appear in Entra ID, stop and review the selected OUs and filtering configuration before allowing further synchronization.

## Wazuh field names

The dashboard displayed the Windows event ID as `data.win.system.eventID`, but that path did not work in a custom rule. The decoder field used in `local_rules.xml` is `win.system.eventID`. I also chained the AD user-creation rule from built-in rule `60109`; matching the event ID alone did not override the built-in result.

## NetExec SMB timeout

My first NetExec run identified `FS01` but timed out before it could authenticate. I checked that both isolated adapters were on `vmbr1`, confirmed SMB was listening on `FS01`, and verified that the Windows firewall allowed TCP 445 from `172.30.30.20`. After that, the bad-password attempts created the expected Event ID `4625` records.
