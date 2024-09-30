# Start logging
$logFile = ".\EnableWindowFeatures.log"
Try {
    Start-Transcript -Path $logFile -ErrorAction Stop
}
catch {
    Start-Transcript -Path $logFile
}

# Print current timestamp
Write-Output "Script started at $(Get-Date)"

Function Is-Administrator {  
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $CurrentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

# Check if the script is running as an administrator	
if (-not (Is-Administrator)) {
    Write-Output "Please run this script as an administrator."
    Exit
}

# Helper function to enable a service if it exists
Function Set-Service-StartupType {
param (
    [string]$Name,
    [string]$StartupType
)

    $service = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($service) {
        Set-Service -Name $Name -StartupType $StartupType
    }
}

# Function to Enable OneDrive Autostart
Function Enable-OneDriveAutostart {
    param (
        [string]$onedrivePath
    )
    Write-Output "Enabling One Drive auto start..."

    # Enable its autostart by setting the value to the OneDrive executable path
    Set-ItemProperty -Path $onedrivePath -Name "OneDrive" -Value "C:\Program Files\Microsoft OneDrive\OneDrive.exe"
    Start-Process -FilePath "C:\Program Files\Microsoft OneDrive\OneDrive.exe"

    Write-Output "One Drive auto start has been enabled..."
}

# Function to enable Windows Auto Update
Function Enable-WindowsAutoUpdate {
    Write-Output "Enabling Windows Auto Update..."

    # Start the Windows Update service
    Start-Service -Name wuauserv

    # Enable the Windows Update service
    Set-Service -Name wuauserv -StartupType Automatic

    # Ensure the registry paths exist
    $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $auPath = "$wuPath\AU"

    if (-not (Test-Path $wuPath)) {
        New-Item -Path $wuPath -Force | Out-Null
    }

    if (-not (Test-Path $auPath)) {
        New-Item -Path $auPath -Force | Out-Null
    }

    # Enable Windows Update through registry
    Remove-ItemProperty -Path $auPath -Name NoAutoUpdate -Force
    Remove-ItemProperty -Path $auPath -Name AUOptions -Force
    Remove-ItemProperty -Path $auPath -Name NoAutoRebootWithLoggedOnUsers -Force

    Write-Output "Windows Auto Update has been enabled."
}

# Function to enable Cortana
Function Enable-Cortana {
    Write-Output "Enabling Cortana..."

    # Define the registry path and key
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    $registryKey = "AllowCortana"

    # Check if the registry path exists, if not, create it
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force
    }

    # Set the registry key to enable Cortana
    Set-ItemProperty -Path $registryPath -Name $registryKey -Value 1

    Write-Output "Cortana has been enabled."
}

# Function to enable Windows Defender
Function Enable-WindowsDefender {
    Write-Output "Enabling Windows Defender..."

    # Enable Windows Defender Real-Time Protection
    Set-MpPreference -DisableRealtimeMonitoring $false

    # Enable Windows Defender Cloud-Based Protection
    Set-MpPreference -MAPSReporting Basic

    # Enable Windows Defender Automatic Sample Submission
    Set-MpPreference -SubmitSamplesConsent SendSafeSamples

    Write-Output "Windows Defender has been enabled."
}

# Function to enable windows notifications
Function Enable-WindowsNotifications {
    Write-Output "Enabling Windows Notifications..."

    # Enable Windows Notifications
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Value 1

    # Enable notifications from other apps
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_TOASTS_ENABLED" -Value 1

    Write-Output "Windows Notifications have been enabled."
}

# Function to enable windows services
Function Enable-Windows-Services {
    # Enable AVCTP service
    Set-Service-StartupType -Name BthAvctpSvc -StartupType Manual

    # Enable Bluetooth Support Service
    Set-Service-StartupType -Name bthserv -StartupType Manual

    # Enable Connected User Experiences and Telemetry
    Set-Service-StartupType -Name DiagTrack -StartupType Automatic

    # Enable Distributed Link Tracking Client
    Set-Service-StartupType -Name TrkWks -StartupType Automatic

    # Enable Downloaded Maps Manager
    Set-Service-StartupType -Name MapsBroker -StartupType Manual

    # Enable Geolocation Service
    Set-Service-StartupType -Name lfsvc -StartupType Manual

    # Enable Infrared Monitor Service
    Set-Service-StartupType -Name Irmon -StartupType Manual

    # Enable Print Spooler
    Set-Service-StartupType -Name Spooler -StartupType Automatic

    # Enable Parental Control
    Set-Service-StartupType -Name WPCSvc -StartupType Manual

    # Enable Windows Update Medic Service
    Set-Service-StartupType -Name WaaSMedicSvc -StartupType Manual

    # Enable Windows Update Service
    Set-Service-StartupType -Name wuauserv -StartupType Automatic

    # Enable Windows Image Acquisition
    Set-Service-StartupType -Name stisvc -StartupType Manual

    # Enable Windows Camera Frame Server
    Set-Service-StartupType -Name FrameServer -StartupType Manual

    # Enable Windows Insider Service
    Set-Service-StartupType -Name wisvc -StartupType Manual
}

# Variables
$onedrivePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$taskName = "DisableWindowFeatures"
$onedriveInstalled = $false

# Check for OneDrive installation
while (-not $onedriveInstalled) {
    $runKeys = Get-ItemProperty -Path $onedrivePath -ErrorAction SilentlyContinue
    if ($runKeys -and $runKeys.PSObject.Properties.Name -contains "OneDrive") {
        $onedriveInstalled = $true
    }
    else {
        Start-Sleep -Seconds 5
    }
}

# Enable OneDrive Autostart
Enable-OneDriveAutostart -onedrivePath $onedrivePath

# Enable Windows Auto Update
Enable-WindowsAutoUpdate

# Enable Cortana
Enable-Cortana

# Enable Windows Defender
Enable-WindowsDefender

# Enable Windows Notifications
Enable-WindowsNotifications

# Enable Windows Services
Enable-Windows-Services

Write-Output "All changes have been reverted."
Stop-Transcript