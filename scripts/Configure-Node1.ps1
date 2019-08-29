[CmdletBinding()]
param(
    [string]
    $SQLServer
)

try {
    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Configure-Node1.ps1.txt -Append

# Enable remote PowerShell and disable local firewall
    enable-psremoting
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

#Disable firewall on SQL server
    $scriptBlock = {
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    }

    Invoke-Command -ScriptBlock $scriptBlock -ComputerName $SQLServer

# Create local share for WSUS content
    New-Item -Path C:\ -Name WSUS -ItemType Directory
    New-SMBShare -Name WSUS -Path "C:\WSUS" -FullAccess "Everyone"

#Install WSUS and DFS services
    Install-WindowsFeature -Name UpdateServices-Services,UpdateServices-DB
    Install-WindowsFeature -Name UpdateServices-Services -IncludeManagementTools
    Install-WindowsFeature FS-DFS-Replication, RSAT-DFS-Mgmt-Con
    Install-WindowsFeature FS-DFS-Namespace

# Set WSUS database location to SQL database
    & 'C:\Program Files\Update Services\Tools\wsusutil.exe' postinstall SQL_INSTANCE_NAME=$SQLServer

# Set variables
    $HostName = (Get-WmiObject Win32_ComputerSystem).Name
    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain
    $DFSPath = ("\\" + $Domain + "\WSUS")
    $LocalPath = ("\\" + $HostName + "\WSUS")

# Create DFS NameSpace root (i.e. \\example.com\WSUS)
    New-DfsnRoot -Path $DFSPath -TargetPath $LocalPath -Type DomainV2

# Set WSUS file storage location to DFS share
    & 'C:\Program Files\Update Services\Tools\wsusutil.exe' postinstall CONTENT_DIR=$DFSPath

# Create DFS replication group
    New-DfsReplicationGroup -GroupName "WSUS" | New-DfsReplicatedFolder -FolderName "WSUS"
    Add-DfsrMember -GroupName "WSUS" -ComputerName $HostName

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}