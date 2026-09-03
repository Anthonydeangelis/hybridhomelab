[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$RootPath = 'C:\Shares',
    [string]$DomainNetbiosName = 'CORP'
)

$ErrorActionPreference = 'Stop'
$shareMap = @{
    public  = @{ Group = 'DL_FileShare_Public_R'; Rights = 'ReadAndExecute' }
    finance = @{ Group = 'DL_FileShare_Finance_RW'; Rights = 'Modify' }
    hr      = @{ Group = 'DL_FileShare_HR_RW'; Rights = 'Modify' }
    it      = @{ Group = 'DL_FileShare_IT_RW'; Rights = 'Modify' }
}

foreach ($entry in $shareMap.GetEnumerator()) {
    $path = Join-Path $RootPath $entry.Key
    if ($PSCmdlet.ShouldProcess($path, 'Create and configure SMB share')) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        if (-not (Get-SmbShare -Name $entry.Key -ErrorAction SilentlyContinue)) {
            New-SmbShare -Name $entry.Key -Path $path -FullAccess "$DomainNetbiosName\Domain Admins" | Out-Null
        }
        $acl = Get-Acl $path
        $acl.SetAccessRuleProtection($true, $false)
        foreach ($identity in @('SYSTEM', "$DomainNetbiosName\Domain Admins")) {
            $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
        }
        $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$DomainNetbiosName\$($entry.Value.Group)", $entry.Value.Rights, 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
        Set-Acl -Path $path -AclObject $acl
    }
}

Write-Host 'Shares configured. Review effective permissions using a non-administrator test account.'
