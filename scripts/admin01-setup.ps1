[CmdletBinding()]
param(
    [string]$DomainName = 'corp.local',
    [string]$DomainNetbiosName = 'CORP',
    [Parameter(Mandatory)]
    [string]$DnsServerAddress,
    [string]$InterfaceAlias = 'Ethernet',
    [switch]$ConfigureDns,
    [switch]$JoinDomain,
    [switch]$InstallRsat,
    [switch]$Verify
)

$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    throw 'Run this script from an elevated PowerShell session.'
}

if ($ConfigureDns) {
    Write-Host "Configuring $InterfaceAlias to use AD DNS $DnsServerAddress..."
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DnsServerAddress
    Resolve-DnsName $DomainName | Out-Host
}

if ($JoinDomain) {
    Write-Host "Joining $DomainName. Use an account allowed to join computers to the domain."
    $credential = Get-Credential -Message "Enter a domain credential such as $DomainNetbiosName\Administrator"
    Add-Computer -DomainName $DomainName -Credential $credential -Restart
    return
}

if ($InstallRsat) {
    Write-Host 'Installing RSAT capabilities. This can take several minutes.'
    Get-WindowsCapability -Name 'RSAT*' -Online |
        Where-Object State -ne 'Installed' |
        Add-WindowsCapability -Online
}

if ($Verify) {
    Write-Host 'DNS servers:'
    Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 |
        Select-Object -ExpandProperty ServerAddresses

    Write-Host 'Domain lookup:'
    Resolve-DnsName $DomainName | Out-Host

    Write-Host 'Computer domain membership:'
    Get-ComputerInfo |
        Select-Object CsName, CsDomain, CsPartOfDomain |
        Format-List

    Write-Host 'Installed RSAT capabilities:'
    Get-WindowsCapability -Name 'RSAT*' -Online |
        Where-Object State -eq 'Installed' |
        Select-Object Name, State |
        Format-Table -AutoSize
}

if (-not ($ConfigureDns -or $JoinDomain -or $InstallRsat -or $Verify)) {
    Write-Host 'No action selected. Use -ConfigureDns, -JoinDomain, -InstallRsat, or -Verify.'
}
