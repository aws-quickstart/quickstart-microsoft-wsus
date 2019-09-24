[CmdletBinding()]
param(
    [string]
    $NewIPAddress,

    [string]
    $NewMask
)

try {

    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Set-IPAddress.ps1.txt -Append

    $GatewayAddress = (Get-NetIPConfiguration).IPv4DefaultGateway.NextHop

    New-NetIPAddress –InterfaceAlias 'Ethernet 2' -IPv4Address $NewIPAddress -PrefixLength $NewMask -DefaultGateway $GatewayAddress
}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}