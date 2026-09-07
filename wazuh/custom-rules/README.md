# Custom Rules

`local_rules.xml` is the copy of the custom rules I used on `WAZUH01`. I tested them one at a time so I could tie each alert to a known action.

The Active Directory rules cover two changes I wanted to see clearly in the dashboard:

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

## Fixing the AD user rule

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

## Validated rules

The current rule set covers:

- `DC01` - AD user creation and group membership changes
- `SYNC01` - Entra Connect / ADSync service stopped
- `FS01` - repeated failed Windows logons
- `WEB01` - sudo command used

## Test order

I tested the rules in this order:

| Order | Rule ID | System | Test action |
| --- | --- | --- | --- |
| 1 | `100101` | `DC01` | Create the disposable `wazuh.test` account. |
| 2 | `100100` | `DC01` | Add the test account to a non-privileged test group, then remove it. |
| 3 | `100110` | `SYNC01` | Stop the Entra Connect / ADSync service, then start it again. |
| 4 | `100120` | `FS01` | Attempt five bad Windows logons within two minutes. |
| 5 | `100200` | `WEB01` | Run a harmless sudo command, such as `sudo whoami`. |

After each test, search the dashboard for the custom rule ID and capture a redacted screenshot showing:

- Rule ID
- Agent name
- Event timestamp
- Description
- Relevant username or service name
