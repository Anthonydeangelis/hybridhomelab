# Wazuh Monitoring and Custom Detections

`WAZUH01` collects events from the Windows and Linux systems in the lab. I tested each custom rule with a specific action on the matching endpoint and saved the results in the main README.

## Coverage

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
