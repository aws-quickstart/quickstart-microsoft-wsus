$outFilePath = '.wsuscleanup.txt' 
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer();   
$cleanupScope = new-object Microsoft.UpdateServices.Administration.CleanupScope;   
$cleanupScope.DeclineSupersededUpdates = $true      
$cleanupScope.DeclineExpiredUpdates     = $true   
$cleanupScope.CleanupObsoleteUpdates   = $true   
$cleanupScope.CompressUpdates         = $true   
$cleanupScope.CleanupObsoleteComputers = $true   
$cleanupScope.CleanupUnneededContentFiles = $true   
$cleanupManager = $wsus.GetCleanupManager();   
$cleanupManager.PerformCleanup($cleanupScope) | Out-File -FilePath $outFilePath 
#Start-Process sqlcmd.exe -Wait -ArgumentList "-S \\.\pipe\Microsoft##WID\tsql\query -i rebuild-susdb-indexes.sql"
#$serverName = hostname
#Start-Process sqlcmd.exe -Wait -ArgumentList "-S ${serverName} -i rebuild-susdb-indexes.sql"