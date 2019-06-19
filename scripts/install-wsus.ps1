param (
    [Parameter(Mandatory=$true)][string] $langs,
    [Parameter(Mandatory=$true)][string] $products,
	[Parameter(Mandatory=$true)][string] $classifications,
	[Parameter(Mandatory=$true)][int] $numOfSyncsPerDay
 )
 
 function CommaSeparatedListToStringCollection(string commaSeparatedList)
 {
	$strList = $commaSeparatedList.split(',');
	$strCol = New-Object -TypeName "System.Collections.Specialized.StringCollection"
	$strList.forEach{
		$strCol.Add($_.trim())
	}
	return $strCol
 }

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
$languages = CommaSeparatedListToStringCollection -commaSeparatedList $langs
$wsusConfig.SetEnabledUpdateLanguages($languages)
$wsusConfig.Save()
 
#Get WSUS Subscription and perform initial synchronization to get latest categories
$subscription = $wsus.GetSubscription()
$subscription.StartSynchronizationForCategoryOnly()
 
While ($subscription.GetSynchronizationStatus() -ne 'NotProcessing') {
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 5
}
Write-Host "Sync is done."

#Configure the Platforms that we want WSUS to receive updates
$productList = CommaSeparatedListToStringCollection -commaSeparatedList $products
Get-WsusProduct | where-Object {
    $_.Product.Title -in $productList
} | Set-WsusProduct
 
#Configure the Classifications
$classificationsList = CommaSeparatedListToStringCollection -commaSeparatedList $classifications
Get-WsusClassification | Where-Object {
    $_.Classification.Title -in $classificationsList
} | Set-WsusClassification
 
#Configure Synchronizations
$subscription.SynchronizeAutomatically=$true
#Set synchronization scheduled for midnight each night
$subscription.SynchronizeAutomaticallyTimeOfDay= (New-TimeSpan -Hours 0)
$subscription.NumberOfSynchronizationsPerDay = $numOfSyncsPerDay
$subscription.Save()
 
#Kick off a synchronization
$subscription.StartSynchronization()