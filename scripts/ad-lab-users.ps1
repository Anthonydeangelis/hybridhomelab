[CmdletBinding()]
param(
    [string]$DomainName = 'corp.local',
    [securestring]$InitialPassword
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

if (-not $InitialPassword) {
    $InitialPassword = Read-Host 'Enter an initial password for the lab users' -AsSecureString
}

$domainDn = (($DomainName -split '\.') | ForEach-Object { "DC=$_" }) -join ','
$users = @(
    @{ GivenName = 'John';  Surname = 'Smith';   Sam = 'jsmith';   Ou = 'IT';      Group = 'GG_IT_Admins';     Title = 'IT Administrator' }
    @{ GivenName = 'Jane';  Surname = 'Doe';     Sam = 'jdoe';     Ou = 'HR';      Group = 'GG_HR_Users';      Title = 'HR Manager' }
    @{ GivenName = 'Bob';   Surname = 'Finance'; Sam = 'bfinance'; Ou = 'Finance'; Group = 'GG_Finance_Users'; Title = 'Finance Analyst' }
    @{ GivenName = 'Alice'; Surname = 'Sales';   Sam = 'asales';   Ou = 'Sales';   Group = 'GG_Sales_Users';   Title = 'Sales Representative' }
    @{ GivenName = 'Mike';  Surname = 'IT';      Sam = 'mit';      Ou = 'IT';      Group = 'GG_IT_Admins';     Title = 'Systems Administrator' }
)

foreach ($user in $users) {
    $account = Get-ADUser -Identity $user.Sam -ErrorAction SilentlyContinue
    if (-not $account) {
        $name = "$($user.GivenName) $($user.Surname)"
        $account = New-ADUser `
            -GivenName $user.GivenName `
            -Surname $user.Surname `
            -Name $name `
            -SamAccountName $user.Sam `
            -UserPrincipalName "$($user.Sam)@$DomainName" `
            -Path "OU=$($user.Ou),$domainDn" `
            -AccountPassword $InitialPassword `
            -Title $user.Title `
            -Department $user.Ou `
            -Company 'CorpLab' `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -PassThru
        Write-Host "Created $name ($($user.Sam))"
    }
    else {
        Write-Host "$($user.Sam) already exists"
    }

    $group = Get-ADGroup -Identity $user.Group
    if ($account.DistinguishedName -notin (Get-ADGroupMember -Identity $group | Select-Object -ExpandProperty DistinguishedName)) {
        Add-ADGroupMember -Identity $group -Members $account
    }
}

Write-Host 'Lab users and group memberships are ready.'
