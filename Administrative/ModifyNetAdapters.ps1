# Check if the script is running with administrative privileges
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # If not, re-launch the script with administrative privileges
    Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File', $PSCommandPath -Verb RunAs
    exit
}

function Disable_NetAdapters {
    Get-NetAdapter | ForEach-Object {
        $adapter = $_
        Disable-NetAdapter -Name $adapter.Name -Confirm:$false
        Write-Warning "Disabling $($adapter.Name)"
    }
}

function Enable_NetAdapters {
    Get-NetAdapter | ForEach-Object {
        $adapter = $_
        Enable-NetAdapter -Name $adapter.Name -Confirm:$false
        Write-Warning "Enabling $($adapter.Name)"
    }    
}

$Decision = Read-Host "
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                               %
% Input which action you would like to perform: %
%                                               %
%           1. Enable NetAdapters               %
%           2. Disable NetAdapters              %
%                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"

if ($Decision -eq "1") {
    Enable_NetAdapters
    Start-Sleep -Seconds 5
    if ((Test-NetConnection -ComputerName "www.google.com").PingSucceeded -ne $true) {
        Write-Output "Ping failed!"
    } else {
        Write-Output "Ping was successful!"
    }
}elseif ($Decision -eq "2") {
    Disable_NetAdapters
    if ((Test-NetConnection -ComputerName "www.google.com").PingSucceeded -ne $true) {
        Write-Output "Ping failed!"
    } else {
        Write-Output "Ping was successful!"
    }
} else {
    Write-Error "ERROR: Invalid input"
}

Read-Host -Prompt "Press Enter to exit"
