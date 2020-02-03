#Preparing download directory
$output = "d:\install\"
New-Item -ItemType Directory -Force -Path $output

#Installing MS ODBC driver
$odbc_url = "https://download.microsoft.com/download/E/6/B/E6BFDC7A-5BCD-4C51-9912-635646DA801E/en-US/msodbcsql_17.4.2.1_x64.msi"
Invoke-WebRequest -Uri $odbc_url -OutFile "${output}msodbcsql_17.4.2.1_x64.msi"
Start-Process msiexec.exe -Wait -ArgumentList "/I ${output}msodbcsql_17.4.2.1_x64.msi /quiet"

#Installing Visual C++ redist
$vc_url = "https://aka.ms/vs/15/release/vc_redist.x64.exe"
Invoke-WebRequest -Uri $vc_url -OutFile "${output}vc_redist.x64.exe"
Start-Process "${output}vc_redist.x64.exe" -Wait -ArgumentList "/install /quiet"

#Downloading SQLCMD
$sqlcmd_url = "https://go.microsoft.com/fwlink/?linkid=2082790"

#Invoke-WebRequest -Uri $ssms_url -OutFile "${output}ssms.exe"
Invoke-WebRequest -Uri $sqlcmd_url -OutFile "${output}sqlcmd.msi"

#Installing SQLCMD
Start-Process msiexec.exe -Wait -ArgumentList "/I ${output}sqlcmd.msi /quiet"
