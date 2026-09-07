# Detection Tests

I used small, repeatable actions to confirm that events from each main system reached Wazuh and matched the custom rules. Every test stayed inside the lab and used disposable accounts or harmless service actions.

## Completed tests

| System | Action | Result |
| --- | --- | --- |
| `DC01` | Created a test user and changed a test group membership | Rules `100101` and `100100` fired |
| `SYNC01` | Stopped and restarted the ADSync service | Rule `100110` fired |
| `FS01` | Sent five bad SMB logons from isolated `KALI01` accounts | Rule `100120` correlated the failures |
| `WEB01` | Ran `sudo whoami` | Rule `100200` fired |

The [Kali runbook](kali-validation-runbook.md) documents the isolated SMB test. The [custom-rule notes](../wazuh/custom-rules/README.md) contain the rule logic and test order.
