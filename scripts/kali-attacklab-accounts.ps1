Import-Module ActiveDirectory

$ouPath = "OU=AttackLab,DC=corp,DC=local"

New-ADOrganizationalUnit `
    -Name "AttackLab" `
    -Path "DC=corp,DC=local" `
    -ProtectedFromAccidentalDeletion $false

$testPassword = Read-Host "Set a password for the disposable test accounts" -AsSecureString

1..5 | ForEach-Object {
    $sam = "spray-test-{0:D2}" -f $_

    New-ADUser `
        -Name $sam `
        -SamAccountName $sam `
        -UserPrincipalName "$sam@corp.local" `
        -Path $ouPath `
        -AccountPassword $testPassword `
        -Enabled $true `
        -ChangePasswordAtLogon $false `
        -Description "Disposable KALI01 Wazuh test account"
}
