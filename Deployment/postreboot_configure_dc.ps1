# Import modules
Import-Module ADDSDeployment
Import-Module ActiveDirectory

# Basic Hardening Steps
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart # Disable SMBv1

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True # Enable Windows Firewall

Set-ADDefaultDomainPasswordPolicy -ComplexityEnabled $true -MinimumPasswordLength 12 -MinimumPasswordAge 1 -MaximumPasswordAge 30 -PasswordHistoryCount 24 # Set strong password policies

Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1 # Configure User Account Control (UAC)

# Enable PowerShell Logging
$regConfig = @" 
regKey,name,value,type
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging","EnableScriptBlockLogging",1,"DWORD"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging","EnableScriptBlockInvocationLogging",1,"DWORD"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging","EnableModuleLogging",1,"DWORD"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames",*,*,"String"
"@

Write-host "Setting up PowerShell registry settings.."
$regConfig | ConvertFrom-Csv | ForEach-Object {
    if(!(Test-Path $_.regKey)){
        Write-Host $_.regKey " does not exist.."
        New-Item $_.regKey -Force
    }
    Write-Host "Setting " $_.regKey
    New-ItemProperty -Path $_.regKey -Name $_.name -Value $_.value -PropertyType $_.type -force
}

# Save the post-reboot script to a file
New-Item -Path $scriptPath -ItemType File -Force
Set-Content -Path $scriptPath -Value $scriptContent

# Create a scheduled task to run the post-reboot script after reboot
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $scriptPath"
$trigger = New-ScheduledTaskTrigger -AtStartup -Delay "00:05:00"
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
Register-ScheduledTask -TaskName $scheduledTaskName -Action $action -Trigger $trigger -Principal $principal

# Restart the server to complete AD DS installation
Restart-Computer -Force
