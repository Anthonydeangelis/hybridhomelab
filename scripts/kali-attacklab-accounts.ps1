[CmdletBinding()]
param(
    [string]$DomainDn = 'DC=corp,DC=local',
    [string]$OuName = 'AttackLab',
    [string]$UserPrefix = 'spray-test',
    [ValidateRange(1, 20)]
    [int]$Count = 5
)

# Run once from ADMIN01 while signed in as a domain administrator.
# These users are intentionally unprivileged and must not be added to
# LabSync, departmental, file-access, or administrative groups.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

$ouPath = "OU=$OuName,$DomainDn"
New-ADOrganizationalUnit -Name $OuName -Path $DomainDn -ProtectedFromAccidentalDeletion $false

$accountPassword = Read-Host 'Set a password for the disposable attack-test accounts' -AsSecureString

1..$Count | ForEach-Object {
    $sam = "$UserPrefix-{0:D2}" -f $_
    New-ADUser `
        -Name $sam `
        -SamAccountName $sam `
        -UserPrincipalName "$sam@corp.local" `
        -Path $ouPath `
        -AccountPassword $accountPassword `
        -Enabled $true `
        -ChangePasswordAtLogon $false `
        -Description 'Disposable KALI01 Wazuh validation account'
}

Get-ADUser -SearchBase $ouPath -Filter * -Properties Enabled |
    Select-Object Name, SamAccountName, Enabled
