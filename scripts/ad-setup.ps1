$OUs = @("IT", "HR", "Finance", "Sales")
foreach ($OU in $OUs) {
    New-ADOrganizationalUnit `
        -Name $OU `
        -Path "DC=corp,DC=local" `
        -ProtectedFromAccidentalDeletion $true
    Write-Host "Created OU: $OU"
}

# ── Global Security Groups (AGDLP — Account layer) ────────
# These hold user accounts, one per department

New-ADGroup -Name "GG_IT_Admins"     -GroupScope Global -GroupCategory Security -Path "OU=IT,DC=corp,DC=local"
New-ADGroup -Name "GG_HR_Users"      -GroupScope Global -GroupCategory Security -Path "OU=HR,DC=corp,DC=local"
New-ADGroup -Name "GG_Finance_Users" -GroupScope Global -GroupCategory Security -Path "OU=Finance,DC=corp,DC=local"
New-ADGroup -Name "GG_Sales_Users"   -GroupScope Global -GroupCategory Security -Path "OU=Sales,DC=corp,DC=local"

Write-Host "Created global security groups"

# ── Domain Local Groups (AGDLP — Permission layer) ────────
# These are assigned to resources (file shares, printers etc.)
# Global groups are nested inside these

New-ADGroup -Name "DL_FileShare_IT_RW"      -GroupScope DomainLocal -GroupCategory Security -Path "DC=corp,DC=local"
New-ADGroup -Name "DL_FileShare_HR_RW"      -GroupScope DomainLocal -GroupCategory Security -Path "DC=corp,DC=local"
New-ADGroup -Name "DL_FileShare_Finance_RW" -GroupScope DomainLocal -GroupCategory Security -Path "DC=corp,DC=local"
New-ADGroup -Name "DL_FileShare_Public_R"   -GroupScope DomainLocal -GroupCategory Security -Path "DC=corp,DC=local"

Write-Host "Created domain local groups"

# ── Nest Global Groups into Domain Local Groups ────────────
# This is the GL step in AGDLP

Add-ADGroupMember -Identity "DL_FileShare_IT_RW"      -Members "GG_IT_Admins"
Add-ADGroupMember -Identity "DL_FileShare_HR_RW"      -Members "GG_HR_Users"
Add-ADGroupMember -Identity "DL_FileShare_Finance_RW" -Members "GG_Finance_Users"
Add-ADGroupMember -Identity "DL_FileShare_Public_R"   -Members "GG_IT_Admins", "GG_HR_Users", "GG_Finance_Users", "GG_Sales_Users"

Write-Host "Nested groups (AGDLP model complete)"

# ── Sample Users ───────────────────────────────────────────
# UPNs use corp.local for now
# Phase 3 updates these to the routable suffix for AD Connect

$DefaultPass = Read-Host 'Enter a password for the disposable lab users' -AsSecureString

$Users = @(
    @{ GivenName="John";  Surname="Smith";   SAM="jsmith";   OU="IT";      Group="GG_IT_Admins";     Title="IT Administrator" },
    @{ GivenName="Jane";  Surname="Doe";     SAM="jdoe";     OU="HR";      Group="GG_HR_Users";      Title="HR Manager" },
    @{ GivenName="Bob";   Surname="Finance"; SAM="bfinance"; OU="Finance"; Group="GG_Finance_Users"; Title="Finance Analyst" },
    @{ GivenName="Alice"; Surname="Sales";   SAM="asales";   OU="Sales";   Group="GG_Sales_Users";   Title="Sales Representative" },
    @{ GivenName="Mike";  Surname="IT";      SAM="mit";      OU="IT";      Group="GG_IT_Admins";     Title="Systems Administrator" }
)

foreach ($User in $Users) {
    $Name = "$($User.GivenName) $($User.Surname)"
    $UPN  = "$($User.SAM)@corp.local"

    New-ADUser `
        -GivenName         $User.GivenName `
        -Surname           $User.Surname `
        -Name              $Name `
        -SamAccountName    $User.SAM `
        -UserPrincipalName $UPN `
        -Path              "OU=$($User.OU),DC=corp,DC=local" `
        -AccountPassword   $DefaultPass `
        -Title             $User.Title `
        -Department        $User.OU `
        -Company           "CorpLab" `
        -Enabled           $true `
        -PasswordNeverExpires $true

    Add-ADGroupMember -Identity $User.Group -Members $User.SAM
    Write-Host "Created user: $Name ($UPN)"
}


# ============================================================
# PHASE 3 — UPN Suffix Update for AD Connect
# Run after Phase 2
# Updates all user UPNs from @corp.local to @yourtenant.onmicrosoft.com
# so AD Connect can sync identities to Entra ID
# ============================================================

# Step 1: Add alternate UPN suffix to the forest
# Replace yourtenant with your actual tenant name
$TenantDomain = "AntDomain525.onmicrosoft.com"

Get-ADForest | Set-ADForest -UPNSuffixes @{Add = $TenantDomain}
Write-Host "Added UPN suffix: $TenantDomain"

# Verify it was added
$Forest = Get-ADForest
Write-Host "Current UPN suffixes: $($Forest.UPNSuffixes)"

# Step 2: Update all user UPNs to the routable suffix
$Users = Get-ADUser -Filter * -Properties UserPrincipalName | Where-Object {
    $_.UserPrincipalName -like "*@corp.local"
}

foreach ($User in $Users) {
    $NewUPN = "$($User.SamAccountName)@$TenantDomain"
    Set-ADUser -Identity $User.SamAccountName -UserPrincipalName $NewUPN
    Write-Host "Updated UPN: $($User.UserPrincipalName) → $NewUPN"
}

# Step 3: Verify UPNs updated
Write-Host "`n── UPN Update Complete ──"
Get-ADUser -Filter * -Properties UserPrincipalName |
    Select-Object Name, SamAccountName, UserPrincipalName |
    Format-Table

Write-Host "`nNext steps:"
Write-Host "1. Deploy AD Connect VM on Proxmox, join to corp.local"
Write-Host "2. Install Entra Connect on that VM"
Write-Host "3. Point it at DC01 and authenticate to your Entra ID tenant"
Write-Host "4. Run initial sync and verify users appear in Entra ID portal"
