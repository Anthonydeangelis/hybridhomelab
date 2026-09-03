# Troubleshooting Notes

## Name resolution

Symptom: the domain controller responds by IP address but not by hostname.

Check:

1. Confirm the client uses the domain controller as its DNS server.
2. Run `nslookup WIN-DC01` and `nslookup WIN-DC01.corp.local`.
3. Confirm the forward lookup zone for `corp.local` exists in DNS Manager.
4. Confirm the server's own network adapter is configured with the appropriate DNS settings.

Do not use public DNS resolvers on a domain-joined machine for AD DNS resolution.

## Domain join failures

Check network reachability, DNS settings, system time, and firewall configuration before retrying the domain join. Record the exact error message in a redacted issue note.

## Entra Connect scope

If unexpected identities appear in Entra ID, stop and review the selected OUs and filtering configuration before allowing further synchronization.
