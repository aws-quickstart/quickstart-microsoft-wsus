try {
    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Install-WSUS.ps1.txt -Append
    
    Install-WindowsFeature -Name UpdateServices-Services,UpdateServices-DB –IncludeManagementTools

    & 'C:\Program Files\Update Services\Tools\wsusutil.exe' postinstall SQL_INSTANCE_NAME="WSFCCluster1"

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}