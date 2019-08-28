[CmdletBinding()]
param(
    [string]
    $SQLServer,
    
    [string]
    $Node1
)

try {
    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Install-WSUS.ps1.txt -Append
    
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
    
    New-DfsnRootTarget -Path $DFSPath -TargetPath $LocalPath

    & 'C:\Program Files\Update Services\Tools\wsusutil.exe' postinstall CONTENT_DIR=$DFSPath

    Add-DfsrMember -GroupName "WSUS" -ComputerName $Node1
    Add-DfsrConnection -GroupName "WSUS" -SourceComputerName $Node1 -DestinationComputerName $HostName
    Set-DfsrMembership -GroupName "WSUS" -FolderName "WSUS" -ContentPath "C:\WSUS" -ComputerName $Node1 -PrimaryMember $True -StagingPathQuotaInMB 16384 -Force
    Set-DfsrMembership -GroupName "WSUS" -FolderName "WSUS" -ContentPath "C:\WSUS" -ComputerName $HostName -StagingPathQuotaInMB 16384 -Force

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}