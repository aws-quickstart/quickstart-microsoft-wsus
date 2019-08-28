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

    Start-Transcript -Path c:\cfn\log\Install-DFSRemote.ps1.txt -Append

    $pass = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName,$pass

    $scriptBlock = {
        Install-WindowsFeature FS-DFS-Replication, RSAT-DFS-Mgmt-Con
        Install-WindowsFeature FS-DFS-Namespace
    }

    Invoke-Command -ScriptBlock $scriptBlock -ComputerName $RemoteHost -Credential $cred

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}