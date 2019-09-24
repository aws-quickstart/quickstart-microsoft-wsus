#Downloading SQLCMD
$sqlcmd_url = "https://go.microsoft.com/fwlink/?linkid=2082790"
$output = "d:\install\"
New-Item -ItemType Directory -Force -Path $output

#Invoke-WebRequest -Uri $ssms_url -OutFile "${output}ssms.exe"
Invoke-WebRequest -Uri $sqlcmd_url -OutFile "${output}sqlcmd.msi"

#Installing SQLCMD
Start-Process msiexec.exe -Wait -ArgumentList "/I ${output}sqlcmd.msi /quiet"
