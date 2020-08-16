# Purpose: Installs a handful of SysInternals tools on the host into c:\Tools\Sysinternals

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing SysInternals Tooling..."
$sysinternalsDir = "C:\Tools\SysInternals"
$sysmonDir = "C:\ProgramData\Sysmon"
If(!(test-path $sysinternalsDir)) {
  New-Item -ItemType Directory -Force -Path $sysinternalsDir
} Else {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Tools directory exists, no need to re-install. Exiting."
  exit
}

If(!(test-path $sysmonDir)) {
  New-Item -ItemType Directory -Force -Path $sysmonDir
} Else {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Sysmon directory exists, no need to re-install. Exiting."
  exit
}

$autorunsPath = "C:\Tools\Sysinternals\Autoruns64.exe"
$procmonPath = "C:\Tools\Sysinternals\Procmon.exe"
$psexecPath = "C:\Tools\Sysinternals\PsExec64.exe"
$procexpPath = "C:\Tools\Sysinternals\procexp64.exe"
$sysmonPath = "C:\Tools\Sysinternals\Sysmon.exe"
$tcpviewPath = "C:\Tools\Sysinternals\Tcpview.exe"
$sysmonConfigPath = "$sysmonDir\sysmonConfig.xml"


# Microsoft likes TLSv1.2 as well
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Autoruns64.exe..."
(New-Object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Autoruns64.exe', $autorunsPath)
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Procmon.exe..."
(New-Object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Procmon.exe', $procmonPath)
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading PsExec64.exe..."
(New-Object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/PsExec64.exe', $psexecPath)
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading procexp64.exe..."
(New-Object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/procexp64.exe', $procexpPath)
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Sysmon.exe..."
(New-Object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Sysmon.exe', $sysmonPath)
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Tcpview.exe..."
(New-Object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Tcpview.exe', $tcpviewPath)
Copy-Item $sysmonPath $sysmonDir

# Download SwiftOnSecurity's Sysmon config
Write-Host "Downloading SwiftOnSecurity's Sysmon config..."
(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml', "$sysmonConfigPath")

# Start Sysmon
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Starting Sysmon..."
Start-Process -FilePath "$sysmonDir\Sysmon.exe" -ArgumentList "-accepteula -i $sysmonConfigPath"
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Verifying that the Sysmon service is running..."
Start-Sleep 5 # Give the service time to start
If ((Get-Service -name Sysmon).Status -ne "Running")
{
  throw "The Sysmon service did not start successfully"
}