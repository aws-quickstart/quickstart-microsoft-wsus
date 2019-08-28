[CmdletBinding()]
param(
    [string]
    $RemoteHost,

    [string]
    $UserName,

    [string]
    $Password
)

try {

    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Disable-RemoteFirewall.ps1.txt -Append

    $pass = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName,$pass

    $scriptBlock = {
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    }

    Invoke-Command -ScriptBlock $scriptBlock -ComputerName $RemoteHost -Credential $cred

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}