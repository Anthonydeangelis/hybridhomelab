# Custom Rules

`local_rules.xml` contains the current tested Wazuh rules from `WAZUH01`. The rules were tested one at a time and are retained here as the publishable configuration reference.

The first validated custom detections focus on Active Directory activity from `DC01`:

- `100101` - new AD user account created
- `100100` - AD group membership changed

On `WAZUH01`, edit the active Wazuh rules file:

```bash
sudo nano /var/ossec/etc/rules/local_rules.xml
```

Before editing, make a quick backup:

```bash
sudo cp /var/ossec/etc/rules/local_rules.xml /var/ossec/etc/rules/local_rules.xml.clean
```

Paste the desired rules, test the XML, then restart:

```bash
sudo /var/ossec/bin/wazuh-logtest
sudo systemctl restart wazuh-manager
sudo systemctl status wazuh-manager --no-pager
```

Keep these rule IDs in the local/custom range and avoid duplicating IDs.

## Issue Encountered: AD User Rule Did Not Match

While testing Active Directory detections, the test account creation event appeared in Wazuh, but it matched the built-in Wazuh rule instead of the custom rule. The alert showed:

- Windows Event ID: `4720`
- Built-in Wazuh rule: `60109`
- Description: `User account enabled or created`
- Test account: `wazuh.test`
- Agent: `win-dc01`

The fix was to chain the custom rule from Wazuh's built-in Windows account creation rule using:

```xml
<if_sid>60109</if_sid>
```

Then the rule was narrowed to Event ID `4720` with an anchored field match:

```xml
<field name="win.system.eventID">^4720$</field>
```

The working description also uses the Wazuh rule field context:

```xml
<description>New AD user account created: $(win.eventdata.targetUserName)</description>
```

After saving the corrected XML and restarting `wazuh-manager`, creating the `wazuh.test` account produced the expected custom alert.

## Validated Rule Pack

The goal is one easy-to-trigger detection per major system:

- `DC01` - AD account disabled
- `SYNC01` - Entra Connect / ADSync service stopped
- `FS01` - repeated failed Windows logons
- `WEB01` - sudo command used

## Test Order

Use this order so each screenshot tells a clean story:

| Order | Rule ID | System | Test action |
| --- | --- | --- | --- |
| 1 | `100102` | `DC01` | Disable the `wazuh.test` account. |
| 2 | `100110` | `SYNC01` | Stop the Entra Connect / ADSync service, then start it again. |
| 3 | `100120` | `FS01` | Attempt five bad Windows logons within two minutes. |
| 4 | `100200` | `WEB01` | Run a harmless sudo command, such as `sudo whoami`. |

After each test, search the dashboard for the custom rule ID and capture a redacted screenshot showing:

- Rule ID
- Agent name
- Event timestamp
- Description
- Relevant username or service name
