# Purpose: Joins a Windows host to the windomain.local domain which was created with "create-domain.ps1".
# Source: https://github.com/StefanScherer/adfs2

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Joining the domain..."

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) First, set DNS to DC to join the domain..."
$newDNSServers = "192.168.38.102"
$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress -match "192.168.38."}
# Don't do this in Azure. If the network adatper description contains "Hyper-V", this won't apply changes.
$adapters | ForEach-Object {if (!($_.Description).Contains("Hyper-V")) {$_.SetDNSServerSearchOrder($newDNSServers)}}

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Now join the domain..."
$hostname = $(hostname)
$user = "windomain.local\vagrant"
$pass = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass

# Place the computer in the correct OU based on hostname
If ($hostname -eq "wef") {
  Add-Computer -DomainName "windomain.local" -credential $DomainCred -OUPath "ou=Servers,dc=windomain,dc=local" -PassThru
} ElseIf ($hostname -eq "win10") {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Adding Win10 to the domain. Sometimes this step times out. If that happens, just run 'vagrant reload win10 --provision'" #debug
  Add-Computer -DomainName "windomain.local" -credential $DomainCred -OUPath "ou=Workstations,dc=windomain,dc=local"
} Else {
  Add-Computer -DomainName "windomain.local" -credential $DomainCred -PassThru
}

Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "vagrant"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "vagrant"

# Stop Windows Update
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling Windows Updates and Windows Module Services"
Set-Service wuauserv -StartupType Disabled
Stop-Service wuauserv
Set-Service TrustedInstaller -StartupType Disabled
Stop-Service TrustedInstaller



# Uninstall Windows Defender from WEF
# This command isn't supported on WIN10
If ($hostname -ne "win10" -And (Get-Service -Name WinDefend -ErrorAction SilentlyContinue).status -eq 'Running') {
  # Uninstalling Windows Defender (https://github.com/StefanScherer/packer-windows/issues/201)
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Uninstalling Windows Defender..."
  Try {
    Uninstall-WindowsFeature Windows-Defender -ErrorAction Stop
    Uninstall-WindowsFeature Windows-Defender-Features -ErrorAction Stop
  } Catch {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Windows Defender did not uninstall successfully..."
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) We'll try again during install-red-team.ps1"
  }
}