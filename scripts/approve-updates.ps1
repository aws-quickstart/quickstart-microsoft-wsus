$wsus = Get-WSUSServer
$sub = $wsus.GetSubscription()

#Waiting for WSUS synchronization to complete
do
{
	$syncStatus = $sub.GetSynchronizationStatus()
	$sub.GetSynchronizationProgress()
	Start-Sleep 60	
} while ($syncStatus -eq "Running")
Write-Host $syncStatus

#Defining a target group for all computers
$group = $wsus.GetComputerTargetGroups() | where {$_.Name -eq 'All Computers'}

function ApproveUpdates($category)
{
	$update = $wsus.SearchUpdates($category)
	$update.forEach{$_.Approve("Install",$Group)}
}

#Approving updates for a number of categories
ApproveUpdates("Windows Server 2019")
ApproveUpdates("Windows Server 2016")
ApproveUpdates("Windows Server 2012 R2")

#Checking WSUS content download progress
$wsus.GetContentDownloadProgress()

#Checking process CPU and memory
while ($true)
{
	Clear-Host
	Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object Name,@{Name='WorkingSet';Expression={($_.WorkingSet64/1KB)}} -First 5
	Start-Sleep 1
}