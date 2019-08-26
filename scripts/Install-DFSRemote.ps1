try {

    param(
    [string]
    $RemoteHost
    )

    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Install-DFSRemote.ps1.txt -Append

    $scriptBlock = {
        Install-WindowsFeature FS-DFS-Replication, RSAT-DFS-Mgmt-Con
        Install-WindowsFeature FS-DFS-Namespace
    }

    Invoke-Command -ScriptBlock $scriptBlock -ComputerName $RemoteHost

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}