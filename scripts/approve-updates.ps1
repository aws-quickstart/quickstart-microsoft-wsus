$wsus = Get-WSUSServer
$update = $wsus.SearchUpdates('Windows Server 2019')
$group = $wsus.GetComputerTargetGroups() | where {$_.Name -eq 'All Computers'}
$update.forEach{$_.Approve("Install",$Group)}