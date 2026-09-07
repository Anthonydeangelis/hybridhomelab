[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9.-]+\.[A-Za-z]{2,}$')]
    [string]$TenantDomain,
    [string]$SyncOuName = 'LabSync',
    [string]$DomainName = 'corp.local'
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
$domainDn = (($DomainName -split '\.') | ForEach-Object { "DC=$_" }) -join ','
$syncOu = "OU=$SyncOuName,$domainDn"

if ($PSCmdlet.ShouldProcess((Get-ADForest).Name, "Add UPN suffix $TenantDomain")) {
    Get-ADForest | Set-ADForest -UPNSuffixes @{ Add = $TenantDomain }
}
Get-ADUser -SearchBase $syncOu -Filter * -Properties UserPrincipalName | ForEach-Object {
    $newUpn = "$($_.SamAccountName)@$TenantDomain"
    if ($PSCmdlet.ShouldProcess($_.SamAccountName, "Set UPN to $newUpn")) {
        Set-ADUser -Identity $_ -UserPrincipalName $newUpn
    }
}

Write-Host "Updated users in $SyncOuName only. Review before configuring Entra Connect Sync."
