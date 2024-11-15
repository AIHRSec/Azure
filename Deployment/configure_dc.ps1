# Define parameters
param (
    [string]$DomainName = "ipt.net",
    [string]$DomainNetbiosName = "IPT.NET",
    [string]$AdminName = "ipt_admin",
    [string]$ServerName = "ipt-dc",
    [securestring]$AdminPassword,
    [securestring]$SafeModeAdminPassword
)

function Postreboot_ConfigureDC {

New-Item -Path C:\Temp -Type Directory
Invoke-WebRequest -Uri https://raw.githubusercontent.com/AIHRSec/Azure/refs/heads/main/Deployment/postreboot_configure_dc.ps1 -OutFile C:\Temp\postreboot_configure_dc.ps1

$scriptPath = "C:\Temp\postreboot_configure_dc.ps1"
$scheduledTaskName = "ConfigureDomainPostReboot"

# Create a scheduled task to run the post-reboot script after reboot
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $scriptPath"
$trigger = New-ScheduledTaskTrigger -AtStartup
$trigger.Delay = "PT2M"
$trigger.Repetition = "False" 
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
Register-ScheduledTask -TaskName $scheduledTaskName -Action $action -Trigger $trigger -Principal $principal

#Restart-Computer -Force
}
Postreboot_ConfigureDC

# Get hostname
$currentName = HOSTNAME.EXE

if ($ServerName -ieq $currentName) {
    Write-Host "Corret Name"
} else {
    Rename-Computer -NewName $ServerName
}

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

# Restart the server to complete AD DS installation
Restart-Computer -Force
