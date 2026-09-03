# Active Directory Design

`DC01` is the on-premises identity foundation for the `corp.local` lab domain. It provides Active Directory Domain Services (AD DS), AD-integrated DNS, organizational units, lab identities, and group-based access control.

## Design goals

- Keep local identities and access control centralized in Active Directory.
- Use organizational units to separate servers, users, groups, and sync-scoped lab identities.
- Use security groups rather than assigning access directly to individual users.
- Administer the domain through `ADMIN01` with RSAT for routine tasks.
- Synchronize only selected lab identities to Microsoft Entra ID through `SYNC01`.

## Access model

The lab uses an AGDLP-style model where practical:

```text
Accounts → Global groups → Domain local groups → Permissions
```

This keeps user membership separate from resource permissions. For example, a user is added to the relevant role-based global group, and the file-share permission is assigned to the domain local group associated with that resource.

## Evidence to publish

- Redacted AD Users and Computers view showing the OU structure.
- Redacted example of group membership supporting AGDLP.
- `dcdiag` or DNS health-check output.
- RSAT administration view from `ADMIN01`.
- A synced disposable lab identity in Microsoft Entra ID, if appropriate.

Do not publish real user details, passwords, recovery information, domain-controller IP addresses, or management paths.
