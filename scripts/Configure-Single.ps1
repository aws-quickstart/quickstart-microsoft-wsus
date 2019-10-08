try {
    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Configure-Single.ps1.txt -Append

# Enable remote PowerShell and disable local firewall
    enable-psremoting
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Create local share for WSUS content
    New-Item -Path C:\ -Name WSUS -ItemType Directory
    New-SMBShare -Name WSUS -Path "C:\WSUS" -FullAccess "Everyone"

#Install WSUS and WID services
    Install-WindowsFeature -Name Windows-Internal-Database
    Install-WindowsFeature -Name UpdateServices-Services
    Install-WindowsFeature -Name UpdateServices-WidDB
    Install-WindowsFeature -Name UpdateServices-Services -IncludeManagementTools

# Set WSUS file storage location to DFS share
    & 'C:\Program Files\Update Services\Tools\wsusutil.exe' postinstall CONTENT_DIR=C:\WSUS
}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}