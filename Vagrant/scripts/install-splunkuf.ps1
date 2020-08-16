# Purpose: Installs a Splunk Universal Forwarder on the host
# Checks for a local version first, otherwise installs from the itnernet.

If (-not (Test-Path "C:\Program Files\SplunkUniversalForwarder\bin\splunk.exe")) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing & Starting Splunk"
  If (-not (Test-Path "C:\vagrant\resources\splunkforwarder-8.0.5-a1a6394cc5ae-x64-release.msi")) {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Local installation package not found, downloading..."
    $msiFile = $env:Temp + "\splunkforwarder-8.0.5-a1a6394cc5ae-x64-release.msi"
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    (New-Object System.Net.WebClient).DownloadFile('https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=windows&version=8.0.5&product=universalforwarder&filename=splunkforwarder-8.0.5-a1a6394cc5ae-x64-release.msi&wget=true', $msiFile)
    Start-Process -FilePath "c:\windows\system32\msiexec.exe" -ArgumentList '/i', "$msiFile", 'RECEIVING_INDEXER="10.1.1.2:9997" AGREETOLICENSE=yes SPLUNKPASSWORD=changeme /quiet' -Wait
  }
  Else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Found local installation package, installing..."
    $msiFile = "C:\vagrant\resources\splunkforwarder-8.0.5-a1a6394cc5ae-x64-release.msi"
    Start-Process -FilePath "c:\windows\system32\msiexec.exe" -ArgumentList '/i', "$msiFile", 'RECEIVING_INDEXER="10.1.1.2:9997" AGREETOLICENSE=yes SPLUNKPASSWORD=changeme /quiet' -Wait

  }
} Else {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Splunk is already installed. Moving on."
}
If ((Get-Service -name splunkforwarder).Status -ne "Running")
{
  throw "Splunk forwarder service not running"
}
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Splunk installation complete!"