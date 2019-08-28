[CmdletBinding()]
param(
    [string]
    $SQLServer
)

try {
    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Install-WSUS.ps1.txt -Append

    enable-psremoting
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    
    $scriptBlock = {
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    }

    Invoke-Command -ScriptBlock $scriptBlock -ComputerName $SQLServer

    New-Item -Path C:\ -Name WSUS -ItemType Directory
    New-SMBShare -Name WSUS -Path "C:\WSUS" -FullAccess "Everyone"

    Install-WindowsFeature -Name UpdateServices-Services,UpdateServices-DB
    Install-WindowsFeature -Name UpdateServices-Services -IncludeManagementTools
    Install-WindowsFeature FS-DFS-Replication, RSAT-DFS-Mgmt-Con
    Install-WindowsFeature FS-DFS-Namespace

    & 'C:\Program Files\Update Services\Tools\wsusutil.exe' postinstall SQL_INSTANCE_NAME=$SQLServer

    $HostName = (Get-WmiObject Win32_ComputerSystem).Name
    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain
    $DFSPath = ("\\" + $Domain + "\WSUS")
    $LocalPath = ("\\" + $HostName + "\WSUS")
    
    New-DfsnRoot -Path $DFSPath -TargetPath $LocalPath -Type DomainV2

    & 'C:\Program Files\Update Services\Tools\wsusutil.exe' postinstall CONTENT_DIR=$DFSPath

    New-DfsReplicationGroup -GroupName "WSUS" | New-DfsReplicatedFolder -FolderName "WSUS"
    Add-DfsrMember -GroupName "WSUS" -ComputerName $HostName

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}