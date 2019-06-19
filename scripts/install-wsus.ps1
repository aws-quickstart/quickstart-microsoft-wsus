Install-WindowsFeature -Name UpdateServices -IncludeManagementTools

New-Item -Path D: -Name WSUS -ItemType Directory
Set-Location -Path "C:\Program Files\Update Services\Tools"
.\wsusutil.exe postinstall CONTENT_DIR=D:\WSUS

#Get WSUS Server Object
$wsus = Get-WSUSServer
#Connect to WSUS server configuration
$wsusConfig = $wsus.GetConfiguration()
 
#Set to download updates from Microsoft Updates
Set-WsusServerSynchronization –SyncFromMU
 
#Set Update Languages to English and save configuration settings
$wsusConfig.AllUpdateLanguagesEnabled = $false           
$wsusConfig.SetEnabledUpdateLanguages(“en”)           
$wsusConfig.Save()
 
#Get WSUS Subscription and perform initial synchronization to get latest categories
$subscription = $wsus.GetSubscription()
$subscription.StartSynchronizationForCategoryOnly()
 
While ($subscription.GetSynchronizationStatus() -ne ‘NotProcessing’) {
    Write-Host “.” -NoNewline
    Start-Sleep -Seconds 5
}
Write-Host “Sync is done.”

#Configure the Platforms that we want WSUS to receive updates
Get-WsusProduct | where-Object {
    $_.Product.Title -in (
    ‘CAPICOM’,
    ‘Silverlight’,
    ‘SQL Server 2008 R2’,
    ‘SQL Server 2005’,
    ‘SQL Server 2008’,
    ‘Exchange Server 2010’,
    ‘Windows Server 2003’,
    ‘Windows Server 2008’,
    ‘Windows Server 2008 R2’)
} | Set-WsusProduct
 
#Configure the Classifications
Get-WsusClassification | Where-Object {
    $_.Classification.Title -in (
    ‘Update Rollups’,
    ‘Security Updates’,
    ‘Critical Updates’,
    ‘Service Packs’,
    ‘Updates’)
} | Set-WsusClassification
 
#Configure Synchronizations
$subscription.SynchronizeAutomatically=$true
#Set synchronization scheduled for midnight each night
$subscription.SynchronizeAutomaticallyTimeOfDay= (New-TimeSpan -Hours 0)
$subscription.NumberOfSynchronizationsPerDay=1
$subscription.Save()
 
#Kick off a synchronization
$subscription.StartSynchronization()