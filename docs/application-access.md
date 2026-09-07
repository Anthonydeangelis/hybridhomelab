# Internal Application Access with Microsoft Entra

`WEB01` hosts an internal Nginx application. I published it through Entra Application Proxy so approved users can reach it without opening an inbound path to the home network.

The design uses Microsoft Entra application publishing / Application Proxy:

```text
Remote user
  -> Microsoft Entra ID authentication
  -> Published enterprise application
  -> Internal connector
  -> WEB01 private web service
```

## Components

| Component | Role |
| --- | --- |
| `WEB01` | Internal Nginx application server |
| Connector host | Runs the Entra Application Proxy connector and can reach `WEB01` internally |
| Microsoft Entra ID | Authenticates assigned users |
| Enterprise Application | Represents the published `WEB01` app |
| Assigned users/groups | Controls who can access the app |

## Access controls and validation

The enterprise application is assigned to the synchronized `GG_Lab_AppProxy_Users` group. Conditional Access requires MFA, and the connector reaches `WEB01` over the private lab network. I tested a successful sign-in with an assigned account and a rejected sign-in with an unassigned account. The connector, MFA prompt, and both access results are shown in the [main README](../README.md#7-private-application-publishing-and-conditional-access).

Only the web application is published. RDP, SMB, Wazuh, Proxmox, and the server itself remain private.
