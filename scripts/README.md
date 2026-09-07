# Scripts

Scripts are starting points for the lab, not unattended production automation. Read each script, use a disposable lab environment, and supply secrets interactively or through secure local tooling.

| Script | Purpose |
| --- | --- |
| `ad-setup.ps1` | Claude-compatible AD workflow: promotion notes, OUs, AGDLP groups, and UPN setup |
| `ad-bootstrap.ps1` | Parameterized alternative for new AD builds |
| `admin01-setup.ps1` | Configure AD DNS, join `ADMIN01` to `corp.local`, install RSAT, and verify management readiness |
| `set-lab-upn.ps1` | Add an alternate UPN suffix and update selected lab users |
| `file-server-setup.ps1` | Create SMB shares and apply AGDLP-based NTFS permissions |
| `wazuh-server-setup.sh` | Install Wazuh all-in-one on `WAZUH01` using the official installation assistant |
| `wazuh-agent-install.sh` | Install a Wazuh agent using a supplied manager address |
| `kali-attacklab-accounts.ps1` | One-time creation of the unprivileged `AttackLab` OU and five disposable FS01 authentication-test accounts |

## VM setup map

| VM | Build path |
| --- | --- |
| `DC01` | Install Windows Server, promote AD DS/DNS, then run `ad-setup.ps1` or `ad-bootstrap.ps1` |
| `ADMIN01` | Install Windows 11 Pro, then run `admin01-setup.ps1` in staged passes |
| `SYNC01` | Install Windows Server, join the domain, then follow `docs/entra-connect-runbook.md` |
| `FS01` | Provision from a clean Windows Server template, join the domain, then run `file-server-setup.ps1` |
| `WEB01` | Provision from the Ubuntu template, then configure the internal Nginx application |
| `WAZUH01` | Provision from the Ubuntu template, run `wazuh-server-setup.sh`, then enroll endpoints with `wazuh-agent-install.sh` |
| `KALI01` | Isolated attacker-simulation VM on internal-only `vmbr1`; see `docs/kali-validation-runbook.md` |

Example `ADMIN01` sequence:

```powershell
.\admin01-setup.ps1 -DnsServerAddress 192.168.1.10 -ConfigureDns -Verify
.\admin01-setup.ps1 -DnsServerAddress 192.168.1.10 -JoinDomain
# After the restart, sign in with the domain admin account.
.\admin01-setup.ps1 -DnsServerAddress 192.168.1.10 -InstallRsat -Verify
```

Replace `192.168.1.10` with the real `DC01` address from your private lab notes. Do not commit private IP evidence unless it is intentionally redacted.
