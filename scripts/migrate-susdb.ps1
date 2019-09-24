$output = "d:\install\"
New-Item -ItemType Directory -Force -Path $output

#Stopping WSUS
Stop-Service IISADMIN
Stop-Service WsusService

#Detaching SUSDB
"USE master
    GO
    ALTER DATABASE SUSDB SET single_user WITH ROLLBACK IMMEDIATE
    GO
    sp_detach_db SUSDB
    GO" > "${output}1-detachSUSDB.sql"
Start-Process sqlcmd.exe -Wait -ArgumentList "-S \\.\pipe\Microsoft##WID\tsql\query -i ${output}1-detachSUSDB.sql"

#Moving SUSDB files from WID to MSSQL
$WIDdir = "${env:windir}\WID\Data\"
$MSSQLdir = "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA"
Move-Item -Path "${WIDdir}SUSDB.mdf" -Destination "${MSSQLdir}SUSDB.mdf"
Move-Item -Path "${WIDdir}SUSDB_log.ldf" -Destination "${MSSQLdir}SUSDB_log.ldf"

#Attaching SUSDB
"USE master;
   GO
   CREATE DATABASE SUSDB
   ON
       (FILENAME = '${MSSQLdir}SUSDB.mdf'),
       (FILENAME = '${MSSQLdir}SUSDB_Log.ldf')
       FOR ATTACH;
   GO" > "${output}2-attachSUSDB.sql"
$serverName = hostname
Start-Process sqlcmd.exe -Wait -ArgumentList "-S ${serverName} -i ${output}2-attachSUSDB.sql"

#Check DB logins
"USE [master]
GO
CREATE LOGIN [NT AUTHORITY\NETWORK SERVICE] FROM WINDOWS WITH DEFAULT_DATABASE=[SUSDB], DEFAULT_LANGUAGE=[us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO" > "${output}3-ServerLoginSUSDB.sql"
Start-Process sqlcmd.exe -Wait -ArgumentList "-S ${serverName} -i ${output}3-ServerLoginSUSDB.sql"

#Edit the registry to point WSUS to the SQL Server Instance
$registryPath = "HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup"
$Name = "SqlServerName"
$value = hostname
New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType ExpandString -Force | Out-Null
Rename-ItemProperty -Path "${registryPath}\Installed Role Services" -Name "UpdateServices-WidDatabase" -NewName "UpdateServices-Database"

#Start WSUS
Start-Service IISADMIN
Start-Service WsusService
