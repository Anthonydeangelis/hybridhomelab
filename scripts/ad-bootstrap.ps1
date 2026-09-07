[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Promote', 'Configure')]
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
$domainDn = (($DomainName -split '\.') | ForEach-Object { "DC=$_" }) -join ','
$ous = 'IT', 'HR', 'Finance', 'Sales', 'LabSync'
foreach ($ou in $ous) {
    $ouPath = "OU=$ou,$domainDn"
    if (-not (Get-ADOrganizationalUnit -Identity $ouPath -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou -Path $domainDn -ProtectedFromAccidentalDeletion $true
    }
}

$globalGroups = @{
    'GG_IT_Admins'            = 'IT'
    'GG_HR_Users'             = 'HR'
    'GG_Finance_Users'        = 'Finance'
    'GG_Sales_Users'          = 'Sales'
    'GG_Lab_AppProxy_Users'   = 'LabSync'
}
foreach ($item in $globalGroups.GetEnumerator()) {
    if (-not (Get-ADGroup -Identity $item.Key -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $item.Key -GroupScope Global -GroupCategory Security -Path "OU=$($item.Value),$domainDn"
    }
}

$localGroups = 'DL_FileShare_IT_RW', 'DL_FileShare_HR_RW', 'DL_FileShare_Finance_RW', 'DL_FileShare_Public_R'
foreach ($group in $localGroups) {
    if (-not (Get-ADGroup -Identity $group -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $group -GroupScope DomainLocal -GroupCategory Security -Path $domainDn
    }
}

$memberships = @{
    'DL_FileShare_IT_RW'      = @('GG_IT_Admins')
    'DL_FileShare_HR_RW'      = @('GG_HR_Users')
    'DL_FileShare_Finance_RW' = @('GG_Finance_Users')
    'DL_FileShare_Public_R'   = @('GG_IT_Admins', 'GG_HR_Users', 'GG_Finance_Users', 'GG_Sales_Users')
}

foreach ($item in $memberships.GetEnumerator()) {
    $currentMembers = Get-ADGroupMember -Identity $item.Key | Select-Object -ExpandProperty DistinguishedName
    foreach ($memberName in $item.Value) {
        $member = Get-ADGroup -Identity $memberName
        if ($member.DistinguishedName -notin $currentMembers) {
            Add-ADGroupMember -Identity $item.Key -Members $member
        }
    }
}

Write-Host 'AD organizational units and AGDLP groups are configured.'
