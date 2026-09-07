# Active Directory Design

`DC01` is the on-premises identity foundation for the `corp.local` lab domain. It provides Active Directory Domain Services (AD DS), AD-integrated DNS, organizational units, lab identities, and group-based access control.

## Layout

| OU | Contents |
| --- | --- |
| `IT`, `HR`, `Finance`, `Sales` | Department users and global security groups |
| `LabSync` | Disposable identities and the group synchronized for Application Proxy access |

I use `ADMIN01` and RSAT for normal directory work instead of signing in to the domain controller. `SYNC01` runs Entra Connect, with OU filtering limited to `LabSync`.

## Access model

The lab uses an AGDLP-style model where practical:

```text
Accounts → Global groups → Domain local groups → Permissions
```

This keeps user membership separate from resource permissions. For example, a user is added to the relevant role-based global group, and the file-share permission is assigned to the domain local group associated with that resource.

The [main README](../README.md#2-active-directory-and-dns--dc01) includes the OU layout, user inventory, and service-health evidence.
