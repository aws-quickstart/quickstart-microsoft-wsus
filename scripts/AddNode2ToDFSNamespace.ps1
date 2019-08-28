[CmdletBinding()]
param(
    [string]
    $DomainName,

    [string]
    $UserName,

    [string]
    $Password
)

try {
    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\AddNode2ToDFSNamespace.ps1.txt -Append

    $hostname = $env:COMPUTERNAME
    $dfspath = ("\\" + $DomainName + "\WSUS")
    $dfstarget = ("\\" + $hostname + "\WSUS")
    $pass = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName,$pass

    New-DfsnRootTarget -Path $dfspath -TargetPath $dfstarget -Credential $cred

    & 'C:\Program Files\Update Services\Tools\wsusutil.exe' postinstall CONTENT_DIR=$dfspath
}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}