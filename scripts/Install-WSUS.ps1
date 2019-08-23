try {
    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Install-WSUS.ps1.txt -Append
    
    Install-WindowsFeature -Name UpdateServices -IncludeManagementTools

    New-Item -Path C: -Name WSUS -ItemType Directory
    & 'C:\Program Files\Update Services\Tools\wsusutil.exe' postinstall CONTENT_DIR=C:\WSUS
}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}