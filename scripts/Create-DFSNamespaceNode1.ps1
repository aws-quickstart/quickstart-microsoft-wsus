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

    Start-Transcript -Path c:\cfn\log\Create-DFSNamespace.ps1.txt -Append

    $hostname = $env:COMPUTERNAME
    $dfspath = ("\\" + $DomainName + "\WSUS")
    $pass = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName,$pass

    New-DfsnRoot -Path $dfspath -TargetPath \\WSUS1\WSUS -Type DomainV2 -Credential $cred

    & 'C:\Program Files\Update Services\Tools\wsusutil.exe' postinstall CONTENT_DIR=$dfspath

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}