# Internal Application Access with Microsoft Entra

## Purpose

`WEB01` hosts the internal web application for the lab. Remote and cloud users should be able to access that application without exposing the home network directly to the internet.

The design uses Microsoft Entra application publishing / Application Proxy:

```text
Remote user
  -> Microsoft Entra ID authentication
  -> Published enterprise application
  -> Internal connector
  -> WEB01 private web service
```

## What this proves

- Internal applications can be published through identity-aware access.
- Users authenticate with Entra ID before reaching the application.
- The home network does not need inbound NAT or public management ports.
- Application access is separate from domain replication or full network connectivity.

## Components

| Component | Role |
| --- | --- |
| `WEB01` | Internal Nginx application server |
| Connector host | Runs the Entra Application Proxy connector and can reach `WEB01` internally |
| Microsoft Entra ID | Authenticates assigned users |
| Enterprise Application | Represents the published `WEB01` app |
| Assigned users/groups | Controls who can access the app |

## Guardrails

- Publish only the intended web application, not RDP, SMB, Wazuh, or administrative interfaces.
- Assign access to a small lab group, not all users.
- Keep `WEB01` private; do not open direct inbound internet access to the server.
- Document any Conditional Access policy used for the app.
- Redact tenant names, connector identifiers, public URLs, and usernames before publishing screenshots.

## Validation checklist

- [ ] `WEB01` web app loads from inside the lab network.
- [ ] Connector is registered and healthy.
- [ ] Enterprise Application is created for the internal web app.
- [ ] Only intended lab users/groups are assigned.
- [ ] Remote browser access requires Entra sign-in.
- [ ] Direct inbound access to `WEB01` remains closed.

## Evidence to capture

- Connector health page.
- Enterprise Application overview.
- User/group assignment page.
- Successful remote access to the published app.
- Redacted sign-in or audit log entry showing application access.
