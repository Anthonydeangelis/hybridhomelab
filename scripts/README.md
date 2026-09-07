# Scripts

These scripts cover the repeatable parts of the lab build. Passwords are prompted for at runtime, and environment-specific values are passed as parameters.

| Script | Purpose |
| --- | --- |
| `ad-bootstrap.ps1` | Promote `DC01`, then create the lab OUs and AGDLP groups |
| `ad-lab-users.ps1` | Create the five sample department users and add their global-group memberships |
| `admin01-setup.ps1` | Configure AD DNS, join `ADMIN01` to `corp.local`, install RSAT, and verify management readiness |
| `set-lab-upn.ps1` | Add an alternate UPN suffix and update selected lab users |
| `file-server-setup.ps1` | Create SMB shares and apply AGDLP-based NTFS permissions |
| `wazuh-server-setup.sh` | Install Wazuh all-in-one on `WAZUH01` using the official installation assistant |
| `wazuh-agent-install.sh` | Install a Wazuh agent using a supplied manager address |
| `kali-attacklab-accounts.ps1` | One-time creation of the unprivileged `AttackLab` OU and five disposable FS01 authentication-test accounts |

## VM setup map

| VM | Build path |
| --- | --- |
| `DC01` | Install Windows Server, run both phases of `ad-bootstrap.ps1`, then run `ad-lab-users.ps1` |
| `ADMIN01` | Install Windows 11 Pro, then run `admin01-setup.ps1` in staged passes |
| `SYNC01` | Install Windows Server, join the domain, then follow `docs/entra-connect-runbook.md` |
| `FS01` | Provision from a clean Windows Server template, join the domain, then run `file-server-setup.ps1` |
| `WEB01` | Provision from the Ubuntu template, then configure the internal Nginx application |
| `WAZUH01` | Provision from the Ubuntu template, run `wazuh-server-setup.sh`, then enroll endpoints with `wazuh-agent-install.sh` |
| `KALI01` | Isolated attacker-simulation VM on internal-only `vmbr1`; see `docs/kali-validation-runbook.md` |

## Example runs

On `DC01`, promotion restarts the server. After the restart, sign back in and run the configuration and user steps:

```powershell
.\ad-bootstrap.ps1 -Phase Promote
.\ad-bootstrap.ps1 -Phase Configure
.\ad-lab-users.ps1
```

On `ADMIN01`:

```powershell
.\admin01-setup.ps1 -DnsServerAddress 192.168.1.10 -ConfigureDns -Verify
.\admin01-setup.ps1 -DnsServerAddress 192.168.1.10 -JoinDomain
# After the restart, sign in with the domain admin account.
.\admin01-setup.ps1 -DnsServerAddress 192.168.1.10 -InstallRsat -Verify
```

Replace `192.168.1.10` with the real `DC01` address from your private lab notes. Do not commit private IP evidence unless it is intentionally redacted.

## KALI01 test accounts

I ran this from an elevated PowerShell window on `ADMIN01`:

```powershell
.\kali-attacklab-accounts.ps1
```

It asks for a password and creates five accounts named `spray-test-01` through `spray-test-05` in the `AttackLab` OU. I copied those usernames into `test-users.txt` on Kali, one per line, then ran:

```bash
nxc smb 172.30.30.10 -d Corp -u test-users.txt -p 'defthewrongpw!'
```

NetExec reads the usernames from the file and tries the password after `-p` against each one. The [Kali validation runbook](../docs/kali-validation-runbook.md) has the full test and the Wazuh results.
