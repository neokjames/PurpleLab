# Import the registry keys
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Making Windows 10 Great again"
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Importing registry keys..."
regedit /s c:\vagrant\scripts\MakeWindows10GreatAgain.reg

# Remove OneDrive from the System
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Removing OneDrive..."
$onedrive = Get-Process onedrive -ErrorAction SilentlyContinue
if ($onedrive) {
  taskkill /f /im OneDrive.exe
}
c:\Windows\SysWOW64\OneDriveSetup.exe /uninstall

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling automatic screen turnoff in order to prevent screen locking..."
powercfg -change -monitor-timeout-ac 0
powercfg -change -standby-timeout-ac 0
powercfg -change -hibernate-timeout-ac 0
