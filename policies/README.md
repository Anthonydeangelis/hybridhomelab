# Azure Policy Notes

Policy assignments should be added only after the Terraform foundation deploys successfully. For this lab, start with audit-oriented built-in policies rather than deny policies that can block experimentation:

- Audit resources missing the `Project`, `Environment`, or `ManagedBy` tags.
- Audit public IPs that are not associated with an approved lab resource.
- Audit Storage Accounts that permit anonymous blob access.

Export or record the policy assignment IDs and scope as redacted evidence. Do not assign an unfamiliar deny policy to the subscription without testing it in a dedicated resource group.
