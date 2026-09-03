# Wazuh Monitoring and Custom Detections

`WAZUH01` is the monitoring platform for the Windows and Linux systems in this lab. The focus is not merely installing an agent; it is validating that useful events reach the dashboard and that targeted custom rules fire for real lab activity.

## What this area demonstrates

- Centralized endpoint monitoring for the lab
- Windows Active Directory event monitoring from `DC01`
- Windows service monitoring from `SYNC01`
- Repeated failed-logon detection on `FS01`
- Linux sudo activity monitoring on `WEB01`
- Custom Wazuh rule tuning and test-driven validation

## Contents

| Path | Purpose |
| --- | --- |
| [`custom-rules/local_rules.xml`](custom-rules/local_rules.xml) | Tested custom rules currently used on `WAZUH01` |
| [`custom-rules/README.md`](custom-rules/README.md) | Rule logic, test order, troubleshooting notes, and evidence guidance |

## Evidence to publish

For each custom rule, publish one redacted alert screenshot showing the rule ID, system/agent, timestamp, description, and the activity that triggered it. Add the matching test note under [`evidence/`](../evidence/README.md).

The Wazuh configuration is a lab-specific example. Do not copy secrets, certificates, endpoint addresses, or unredacted Wazuh configuration into a public repository.
