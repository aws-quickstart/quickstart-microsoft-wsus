[CmdletBinding()]
param(
    [string]
    $RemoteHost,

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

    Enable-PSRemoting -Force

    $pass = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName,$pass

    $scriptBlock = {
        $hostname = $env:COMPUTERNAME
        $dfspath = ("\\" + $DomainName + "\WSUS")
        $localpath = ("\\" + $hostname + "\WSUS")
        New-DfsnRoot -Path $dfspath -TargetPath $localpath -Type DomainV2 -Credential $cred
    }

    Invoke-Command -ScriptBlock $scriptBlock -Credential $cred

    & 'C:\Program Files\Update Services\Tools\wsusutil.exe' postinstall CONTENT_DIR=$dfspath

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}