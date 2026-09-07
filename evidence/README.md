# Evidence

This folder contains screenshots from controlled tests in the homelab. They support the claims in the repository README and use lab-only identities.

## Suggested folder structure

```text
evidence/
  ad/
  entra-connect/
  app-proxy/
  conditional-access/
  web01/
  wazuh/
  kali/
  azure/
```

## Publishing notes

Do not add passwords, recovery keys, private keys, tokens, tenant or subscription IDs, or sensitive production data. Screenshots in this repository are from a disposable lab environment.

The two former report-only Conditional Access captures are intentionally not published because the policy is now enabled; the README documents the final enabled-policy validation flow instead.

## Evidence notes template

Use this format when adding a screenshot or command output:

```text
Area:
System:
Action tested:
Expected result:
Observed result:
Screenshot/file:
Cleanup:
```

## Current versus upcoming evidence

| Area | Status | Publish when available |
| --- | --- | --- |
| AD and DNS | Published | Additional group-nesting or `dcdiag` evidence, if captured later |
| Entra Connect | Published | Additional synchronization-service result, if captured later |
| App Proxy and Conditional Access | Published | Policy-configuration or sign-in-log evidence, if captured later |
| WEB01 | Published | Additional service-status evidence, if captured later |
| Wazuh | Published | Additional per-rule detail evidence, if captured later |
| FS01 | Wazuh failed-logon alert published | Share, ACL, and authorized/denied SMB access evidence, if captured later |
| Azure Terraform and web administration | Published | Terraform apply, resources, HTTPS, Key Vault role and secret, Key Vault-read validation, and protected `/admin/` access |
| KALI01 validation | Published | `AttackLab` account inventory and the FS01 Event ID 4625 / Wazuh rule 100120 correlation alert |
