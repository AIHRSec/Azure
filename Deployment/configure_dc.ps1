# Define parameters
param (
    [string]$DomainName = "ipt.net",
    [string]$DomainNetbiosName = "IPT",
    [string]$AdminName = "ipt_admin",
    [string]$ServerName = "ipt-dc",
    [securestring]$AdminPassword
)

# Install the AD-Domain-Services role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Import the ADDSDeployment module
Import-Module ADDSDeployment

# Install a new AD forest
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetbiosName `
    -SafeModeAdministratorPassword $AdminPassword `
    -InstallDNS `
    -Force

# Schedule the post-reboot script
$scriptPath = "C:\scripts\PostReboot-Configure-DC.ps1"
$scheduledTaskName = "ConfigureDomainPostReboot"

$scriptContent = @"
# Post-reboot script to complete configuration

# Import necessary modules
Import-Module ADDSDeployment
Import-Module ActiveDirectory

# Create a new admin user
New-ADUser -Name $AdminName -SamAccountName $AdminName -UserPrincipalName "$AdminName@$DomainName" -AccountPassword (ConvertTo-SecureString -AsPlainText "$AdminPassword" -Force) -Enabled $true

# Add the new admin user to the Domain Admins group
Add-ADGroupMember -Identity "Domain Admins" -Members $AdminName

# Basic Hardening Steps

# Disable SMBv1
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart

# Enable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Set strong password policies
Set-ADDefaultDomainPasswordPolicy -ComplexityEnabled $true -MinimumPasswordLength 12 -MinimumPasswordAge 1 -MaximumPasswordAge 30 -PasswordHistoryCount 24

# Configure User Account Control (UAC)
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1

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

Write-Host "Post-reboot configuration completed."
"@

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
