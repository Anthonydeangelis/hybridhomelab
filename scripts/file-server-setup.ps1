[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$RootPath = 'C:\Shares',
    [string]$DomainNetbiosName = 'CORP'
)

$ErrorActionPreference = 'Stop'
$shareMap = @{
    public  = @{ Group = 'DL_FileShare_Public_R'; NtfsRights = 'ReadAndExecute'; ShareRight = 'Read' }
    finance = @{ Group = 'DL_FileShare_Finance_RW'; NtfsRights = 'Modify'; ShareRight = 'Change' }
    hr      = @{ Group = 'DL_FileShare_HR_RW'; NtfsRights = 'Modify'; ShareRight = 'Change' }
    it      = @{ Group = 'DL_FileShare_IT_RW'; NtfsRights = 'Modify'; ShareRight = 'Change' }
}

foreach ($entry in $shareMap.GetEnumerator()) {
    $path = Join-Path $RootPath $entry.Key
    if ($PSCmdlet.ShouldProcess($path, 'Create and configure SMB share')) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        if (-not (Get-SmbShare -Name $entry.Key -ErrorAction SilentlyContinue)) {
            New-SmbShare -Name $entry.Key -Path $path -FullAccess "$DomainNetbiosName\Domain Admins" | Out-Null
        }
        $accountName = "$DomainNetbiosName\$($entry.Value.Group)"
        $shareAccess = Get-SmbShareAccess -Name $entry.Key |
            Where-Object AccountName -eq $accountName
        if ($shareAccess.AccessRight -ne $entry.Value.ShareRight) {
            if ($shareAccess) {
                Revoke-SmbShareAccess -Name $entry.Key -AccountName $accountName -Force
            }
            Grant-SmbShareAccess `
                -Name $entry.Key `
                -AccountName $accountName `
                -AccessRight $entry.Value.ShareRight `
                -Force | Out-Null
        }

        $acl = Get-Acl $path
        $acl.SetAccessRuleProtection($true, $false)
        foreach ($identity in @('SYSTEM', "$DomainNetbiosName\Domain Admins")) {
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
            $acl.SetAccessRule($rule)
        }
        $groupRule = New-Object System.Security.AccessControl.FileSystemAccessRule($accountName, $entry.Value.NtfsRights, 'ContainerInherit,ObjectInherit', 'None', 'Allow')
        $acl.SetAccessRule($groupRule)
        Set-Acl -Path $path -AclObject $acl
    }
}

Write-Host 'Shares configured. Review effective permissions using a non-administrator test account.'
