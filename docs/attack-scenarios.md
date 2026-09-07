# Controlled Validation Scenarios

These exercises are for the owner's isolated homelab only. Do not run them against public IPs, shared home devices, school systems, or any system without explicit authorization.

## Preconditions

- `KALI01` is isolated with enforceable network rules.
- Only disposable lab accounts and approved target VMs are in scope.
- Wazuh agents are healthy on the intended targets.
- A rollback path and evidence-capture plan exist.

## KALI01 validation host

`KALI01` is the dedicated attacker-simulation VM for the lab. It exists to generate controlled, authorized activity against lab-owned targets so monitoring and response can be validated.

Do not use `KALI01` against public systems, school systems, work systems, shared home devices, or any target that is not explicitly part of this lab.

## Completed validation: FS01 SMB failed-logon correlation

The first completed Kali exercise is documented in the [KALI01 validation runbook](kali-validation-runbook.md). `KALI01` is isolated on an internal-only Proxmox bridge and can reach only the second `FS01` adapter over SMB. Five disposable `AttackLab` identities receive one deliberately incorrect SMB password attempt each. Wazuh records the underlying Windows Event ID `4625` events and correlates the threshold with custom rule `100120`.

## Evidence-focused scenarios

| Scenario | Objective | Expected evidence |
| --- | --- | --- |
| Service discovery | Validate visibility of an approved lab service | Wazuh / host firewall log and scope record |
| Failed-authentication threshold | Verify account lockout and audit policy with a disposable user | Windows failed-logon and lockout events |
| Privileged-group change | Use a test account to validate auditing of a controlled membership change | AD security event and Wazuh alert |
| Service stop / start | Validate monitoring of a non-critical test service | Service-control event and Wazuh alert |

Record the exact scope, time, test account, expected result, observed result, and cleanup action for every scenario.

## Custom Wazuh Rules

Validated custom rules are stored in `wazuh/custom-rules/local_rules.xml`. The related rule logic and test order are documented in `wazuh/custom-rules/README.md`.

The current small validation pack covers:

- `DC01`: Active Directory account activity.
- `SYNC01`: Entra Connect / ADSync service stop.
- `FS01`: repeated failed logons against the file server.
- `WEB01`: sudo usage on the Linux web server.
