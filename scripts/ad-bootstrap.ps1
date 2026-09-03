[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Promote','Configure')]
    [string]$Phase,
    [string]$DomainName = 'corp.local',
    [string]$NetbiosName = 'CORP',
    [securestring]$SafeModeAdministratorPassword
)

$ErrorActionPreference = 'Stop'

if ($Phase -eq 'Promote') {
    if (-not $SafeModeAdministratorPassword) {
        $SafeModeAdministratorPassword = Read-Host 'Enter a DSRM password' -AsSecureString
    }
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    Import-Module ADDSDeployment
    Install-ADDSForest -DomainName $DomainName -DomainNetbiosName $NetbiosName `
        -SafeModeAdministratorPassword $SafeModeAdministratorPassword -InstallDns -Force
    return
}

Import-Module ActiveDirectory
$domainDn = ($DomainName -split '\.') | ForEach-Object { "DC=$_" } -join ','
$ous = 'IT','HR','Finance','Sales','LabSync'
foreach ($ou in $ous) {
    if (-not (Get-ADOrganizationalUnit -LDAPFilter "(ou=$ou)" -SearchBase $domainDn -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou -Path $domainDn -ProtectedFromAccidentalDeletion $true
    }
}

$globalGroups = @{
    'GG_IT_Admins' = 'IT'; 'GG_HR_Users' = 'HR'; 'GG_Finance_Users' = 'Finance'; 'GG_Sales_Users' = 'Sales'; 'GG_LabSync_Users' = 'LabSync'
}
foreach ($item in $globalGroups.GetEnumerator()) {
    if (-not (Get-ADGroup -Filter "Name -eq '$($item.Key)'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $item.Key -GroupScope Global -GroupCategory Security -Path "OU=$($item.Value),$domainDn"
    }
}

$localGroups = 'DL_FileShare_IT_RW','DL_FileShare_HR_RW','DL_FileShare_Finance_RW','DL_FileShare_Public_R'
foreach ($group in $localGroups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$group'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $group -GroupScope DomainLocal -GroupCategory Security -Path $domainDn
    }
}

@{
    'DL_FileShare_IT_RW' = 'GG_IT_Admins'; 'DL_FileShare_HR_RW' = 'GG_HR_Users'; 'DL_FileShare_Finance_RW' = 'GG_Finance_Users'
}.GetEnumerator() | ForEach-Object {
    Add-ADGroupMember -Identity $_.Key -Members $_.Value -ErrorAction SilentlyContinue
}

Write-Host 'AD organizational units and AGDLP groups are configured.'
