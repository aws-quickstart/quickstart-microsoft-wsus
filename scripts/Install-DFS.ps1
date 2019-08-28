try {
    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Install-DFS.ps1.txt -Append

    New-Item -Path C:\ -Name WSUS -ItemType Directory

    New-SMBShare -Name WSUS -Path "C:\WSUS" -FullAccess "Everyone"

    Install-WindowsFeature FS-DFS-Replication, RSAT-DFS-Mgmt-Con
    Install-WindowsFeature FS-DFS-Namespace

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}