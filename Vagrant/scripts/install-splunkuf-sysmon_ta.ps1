# Purpose: Installs the Splunk Universal Forwarder Sysmon Technical Add-On

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing the Sysmon TA for Splunk"

If (Test-Path "C:\Program Files\SplunkUniversalForwarder\etc\apps\TA-microsoft-sysmon\default") {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Sysmon TA is already installed. Moving on."
  Exit 0
}

# Install Sysmon TA
$sysmontaPath = "C:\vagrant\resources\splunk_forwarder\splunk-add-on-for-microsoft-sysmon_1062.tgz"
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing the Sysmon TA"
Start-Process -FilePath "C:\Program Files\SplunkUniversalForwarder\bin\splunk.exe" -ArgumentList "install app $sysmontaPath -auth admin:changeme" -NoNewWindow

# Create local directory
If (Test-Path "C:\Program Files\SplunkUniversalForwarder\etc\apps\TA-microsoft-sysmon\default") {
  $inputsPath = "C:\Program Files\SplunkUniversalForwarder\etc\apps\TA-microsoft-sysmon\local\inputs.conf"
  New-Item -ItemType Directory -Force -Path "C:\Program Files\SplunkUniversalForwarder\etc\apps\TA-microsoft-sysmon\local"
  Copy-Item c:\vagrant\resources\splunk_forwarder\sysmon_ta_inputs.conf $inputsPath -Force
}

# Add a check here to make sure the TA was installed correctly
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Sleeping for 15 seconds"
Start-Sleep -s 15
If (Test-Path "C:\Program Files\SplunkUniversalForwarder\etc\apps\TA-microsoft-sysmon\default") {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Sysmon TA installed successfully."
} Else {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Something went wrong during installation."
  exit 1
}