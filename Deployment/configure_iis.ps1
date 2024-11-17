function precheck {    

# Get Hostname
$currentName = HOSTNAME.EXE
$ServerName = "ipt-iis"

# Verify Hostname
if ($ServerName -ieq $currentName) {
    Write-Host "Corret Name"
} else {
    Rename-Computer -NewName $ServerName
}

# Some Hardening
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart # Disable SMBv1
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True # Enable Windows Firewall
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

# Set Language
#Install-Language es-CO -CopyToSettings
Set-WinSystemLocale es-CO
Set-WinUILanguageOverride es-CO
#Set-WinUserLanguageList es-CO -Force

}
precheck

function iis_config {

# Install IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools
# Create a basic HTML page
$website = "IPT_Site"
$indexPath = "C:\inetpub\wwwroot\$website\index.html"
$indexContent = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Innova PetroTec - Soluciones Energéticas Innovadoras</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #004080;
            color: white;
            padding: 20px;
            text-align: center;
        }
        nav {
            display: flex;
            justify-content: center;
            background-color: #003366;
        }
        nav a {
            color: white;
            padding: 14px 20px;
            text-decoration: none;
            text-align: center;
        }
        nav a:hover {
            background-color: #002244;
        }
        main {
            padding: 20px;
        }
        footer {
            background-color: #004080;
            color: white;
            text-align: center;
            padding: 10px;
            position: fixed;
            bottom: 0;
            width: 100%;
        }
    </style>
</head>
<body>
    <header>
        <h1>Innova PetroTec</h1>
        <p>Soluciones Energéticas Innovadoras</p>
    </header>
    <nav>
        <a href="#home">Inicio</a>
        <a href="#about">Nosotros</a>
        <a href="#services">Servicios</a>
        <a href="#contact">Contacto</a>
    </nav>
    <main>
        <section id="home">
            <h2>¡Bienvenidos a Innova PetroTec!</h2>
            <p>Innova PetroTec es una empresa líder en el sector de petróleo y energía en Sudamérica.</p>
            <p>Nos enorgullece ofrecer soluciones innovadoras y sostenibles para el futuro energético de nuestra región.</p>
        </section>
        <section id="about">
            <h2>Sobre Nosotros</h2>
            <p>Con más de 10 años de experiencia, nos especializamos en la exploración, extracción y producción de energía limpia.</p>
        </section>
        <section id="services">
            <h2>Nuestros Servicios</h2>
            <ul>
                <li>Exploración y producción de petróleo</li>
                <li>Soluciones energéticas sostenibles</li>
                <li>Consultoría y asesoramiento técnico</li>
            </ul>
        </section>
        <section id="contact">
            <h2>Contacto</h2>
            <p>Dirección: </p>
            <p>Teléfono: </p>
            <p>Email: </p>
        </section>
    </main>
    <footer>
        <p>© 2024 Innova PetroTec. Todos los derechos reservados.</p>
    </footer>
</body>
</html>
"@
# Removing old site
Remove-Website -Name "Default Web Site"
# Example: Create a new website
New-Item -Path "C:\inetpub\wwwroot\$website" -Type Directory
New-Website -Name $website -Port 80 -PhysicalPath "C:\inetpub\wwwroot\$website" -ApplicationPool "DefaultAppPool"
Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
Restart-Service -Name "W3SVC"
}
iis_config

function configure_logging {
# Import the WebAdministration module
Import-Module WebAdministration

# Get the list of all IIS sites
$sites = Get-Website

# Loop through each site to get the logging configuration
foreach ($site in $sites) {
    $siteName = $site.name
    
    # Get the logging configuration for the site
    $logPath = Get-WebConfigurationProperty -Filter "system.applicationHost/sites/site[@name='$siteName']/logFile" -name "directory"
    $logFormat = Get-WebConfigurationProperty -Filter "system.applicationHost/sites/site[@name='$siteName']/logFile" -name "logFormat"
    $logPeriod = Get-WebConfigurationProperty -Filter "system.applicationHost/sites/site[@name='$siteName']/logFile" -name "period"
    $logTruncateSize = Get-WebConfigurationProperty -Filter "system.applicationHost/sites/site[@name='$siteName']/logFile" -name "truncateSize"

    # Display the site name and its logging configuration
    Write-Output "Site Name: $siteName"
    Write-Output "Log Path: $logPath"
    Write-Output "Log Format: $logFormat"
    Write-Output "Log Period: $logPeriod"
    Write-Output "Log Truncate Size: $logTruncateSize"
    Write-Output ""
}
    
}

# Restart the server following the complete of installation
Write-Host "Rebooting server in 20 seconds"
Start-Sleep -Seconds 20
Restart-Computer -Force
