# Microsoft Entra Connect Sync Runbook

## Prerequisites

- `DC01` and AD DNS are healthy.
- `SYNC01` is domain joined and uses `DC01` for DNS.
- A dedicated synchronization OU exists and contains only disposable lab accounts.
- The chosen Entra tenant and tenant-domain suffix are confirmed.

## Procedure

1. Add the tenant's `onmicrosoft.com` suffix as an alternate UPN suffix in the forest.
2. Update only the lab users that will sync to use that suffix.
3. Install Microsoft Entra Connect Sync on `SYNC01`, not on the domain controller.
4. Select the intended existing tenant.
5. Use password hash synchronization for the lab unless a different documented requirement exists.
6. Limit OU filtering to the dedicated sync OU.
7. Run the initial sync and verify the expected test user and group in Microsoft Entra ID.

## Guardrails

- Do not synchronize personal accounts, administrator accounts, or whole departments by default.
- Do not use an `onmicrosoft.com` UPN as a production-domain recommendation; it is a lab constraint.
- Entra Connect Sync does not provide network connectivity to the home lab.
