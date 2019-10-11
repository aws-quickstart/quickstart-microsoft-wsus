[CmdletBinding()]
# Incoming Parameters for Script, CloudFormation\SSM Parameters being passed in
param(
    [Parameter(Mandatory=$true)]
    [string]$InstanceName,

    [Parameter(Mandatory=$true)]
    [string]$DomainNetBIOSName,

    [Parameter(Mandatory=$true)]
    [string]$DomainDNSName,

    [Parameter(Mandatory=$true)]
    [string]$AdminSecret
)


$Admin = ConvertFrom-Json -InputObject (Get-SECSecretValue -SecretId $AdminSecret).SecretString
$AdminUser = "{0}\{1}" -f $DomainNetBIOSName, $Admin.UserName
# Creating Credential Object for Administrator
$Credentials = (New-Object PSCredential($AdminUser,(ConvertTo-SecureString $Admin.Password -AsPlainText -Force)))
# Getting the DSC Cert Encryption Thumbprint to Secure the MOF File
$DscCertThumbprint = (get-childitem -path cert:\LocalMachine\My | where { $_.subject -eq "CN=AWSQSDscEncryptCert" }).Thumbprint
# Getting the Name Tag of the Instance
# $NameTag = (Get-EC2Tag -Filter @{ Name="resource-id";Values=(Invoke-RestMethod -Method Get -Uri http://169.254.169.254/latest/meta-data/instance-id)}| Where-Object { $_.Key -eq "Name" })
$NewName = $InstanceName

# Creating Configuration Data Block that has the Certificate Information for DSC Configuration Processing
$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName="*"
            CertificateFile = "C:\AWSQuickstart\publickeys\AWSQSDscPublicKey.cer"
            Thumbprint = $DscCertThumbprint
            PSDscAllowDomainUser = $true
        },
        @{
            NodeName = 'localhost'
        }
    )
}

Configuration DomainJoin {
    param(
        [PSCredential] $Credentials
    )

    Import-Module -Name PSDesiredStateConfiguration
    Import-Module -Name ComputerManagementDsc
    
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module ComputerManagementDsc

    Node 'localhost' {

        Computer JoinDomain {
            Name = $NewName
            DomainName = $DomainDNSName
            Credential = $Credentials
        }
    }
}

DomainJoin -OutputPath 'C:\AWSQuickstart\DomainJoin' -ConfigurationData $ConfigurationData -Credentials $Credentials