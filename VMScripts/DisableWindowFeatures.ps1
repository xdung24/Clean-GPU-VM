# Start logging
$logFile = ".\DisableWindowFeatures.log"
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
        Write-Output "Service '$Name' has been set to '$StartupType'."
    }
}

# Function to set registry property if the key exists
function Set-RegistryPropertyIfExists {
    param (
        [string]$Path,
        [string]$Name,
        [object]$Value
    )
    if (Test-Path $Path) {
        Set-ItemProperty -Path $Path -Name $Name -Value $Value
        Write-Output "Registry property '$Name' has been set to '$Value'."
    }
}

# Function to remove registry property if the key exists
function Remove-RegistryPropertyIfExists {
    param (
        [string]$Path,
        [string]$Name
    )
    if (Test-Path $Path) {
        Remove-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
        Write-Output "Registry property '$Name' has been removed."
    }
}

# Function to Disable OneDrive Autostart
Function Disable-OneDriveAutostart {
    param (
        [string]$onedrivePath
    )
    Write-Output "Disabling One Drive auto start..."

    # Disable its autostart by setting the value to an empty string
    Set-ItemProperty -Path $onedrivePath -Name "OneDrive" -Value ""
    Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force

    Write-Output "One Drive auto start has been disabled..."
}

# Function to disable Windows Auto Update
Function Disable-WindowsAutoUpdate {
    # DisableAutoUpdate
    Write-Output "Disabling Windows Auto Update..."

    # Stop the Windows Update service
    Stop-Service -Name wuauserv -Force

    # Disable the Windows Update service
    Set-Service -Name wuauserv -StartupType Disabled

    # Ensure the registry paths exist
    $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $auPath = "$wuPath\AU"

    if (-not (Test-Path $wuPath)) {
        New-Item -Path $wuPath -Force | Out-Null
    }

    if (-not (Test-Path $auPath)) {
        New-Item -Path $auPath -Force | Out-Null
    }

    # Disable Windows Update through registry
    Set-ItemProperty -Path $auPath -Name NoAutoUpdate -Value 1 -Force
    Set-ItemProperty -Path $auPath -Name AUOptions -Value 1 -Force
    Set-ItemProperty -Path $auPath -Name NoAutoRebootWithLoggedOnUsers -Value 1 -Force
    Set-ItemProperty -Path $auPath -Name NoAutoUpdate -Value 1 -Force

    Write-Output "Windows Auto Update has been disabled."
}

# Function to disable Cortana
Function Disable-Cortana {
    Write-Output "Disabling Cortana..."

    # Define the registry path and key
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    $registryKey = "AllowCortana"

    # Check if the registry path exists, if not, create it
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force
    }

    # Set the registry key to disable Cortana
    Set-ItemProperty -Path $registryPath -Name $registryKey -Value 0

    Write-Output "Cortana has been disabled."
}

# Function to disable Windows Defender
Function Disable-WindowsDefender {
    Write-Output "Disabling Windows Defender..."

    # Disable Windows Defender Real-Time Protection
    Set-MpPreference -DisableRealtimeMonitoring $true

    # Disable Windows Defender Cloud-Based Protection
    Set-MpPreference -MAPSReporting Disabled

    # Disable Windows Defender Automatic Sample Submission
    Set-MpPreference -SubmitSamplesConsent NeverSend

    Write-Output "Windows Defender has been disabled."
}

# Function to disable windows notifications
Function Disable-WindowsNotifications {
    Write-Output "Disabling Windows Notifications..."

    # Disable Windows Notifications
    Set-RegistryPropertyIfExists -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Value 0

    # Disable notifications from other apps
    Set-RegistryPropertyIfExists -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_TOASTS_ENABLED" -Value 0

    # Remove the Console lock display off timeout
    Set-RegistryPropertyIfExists -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\7516b95f-f776-4464-8c53-06167f40cc99\8EC4B3A5-6868-48c2-BE75-4F3044BE88A7" -Name "Attributes" -Value 2

    # Notifications
    Set-RegistryPropertyIfExists -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "TaskbarNoNotification" -Value 1
    Remove-RegistryPropertyIfExists -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "TaskbarNoNotification"
    Remove-RegistryPropertyIfExists -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableBalloonTips"
    Remove-RegistryPropertyIfExists -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableBalloonTips"

    # Toast
    Set-RegistryPropertyIfExists -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "NoToastApplicationNotification" -Value 1

    # Action Centre
    Set-RegistryPropertyIfExists -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Value 1

    # Hero Paper
    Set-RegistryPropertyIfExists -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableLogonBackgroundImage" -Value 1

    # Immersive Shell
    Set-RegistryPropertyIfExists -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell" -Name "UseActionCenterExperience" -Value 0

    # LUA
    Set-RegistryPropertyIfExists -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

    # Updates
    Set-RegistryPropertyIfExists -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1

    # WiFi Sense
    Set-RegistryPropertyIfExists -Path "HKLM:\Software\Microsoft\WcmSvc\wifinetworkmanager" -Name "WiFiSenseCredShared" -Value 0
    Set-RegistryPropertyIfExists -Path "HKLM:\Software\Microsoft\WcmSvc\wifinetworkmanager" -Name "WiFiSenseOpen" -Value 0

    # No Lock Screen
    Set-RegistryPropertyIfExists -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Value 1

    # Quiet Mode
    Set-RegistryPropertyIfExists -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_TOASTS_ENABLED" -Value 0
    Write-Output "Windows Notifications have been disabled."
}

# Function to disable windows services
Function Disable-Windows-Services {
    # Disable AVCTP service
    Set-Service-StartupType -Name BthAvctpSvc -StartupType Disabled

    # Disable Bluetooth Support Service
    Set-Service-StartupType -Name bthserv -StartupType Disabled

    # Disable Connected User Experiences and Telemetry
    Set-Service-StartupType -Name DiagTrack -StartupType Disabled

    # Disable Distributed Link Tracking Client
    Set-Service-StartupType -Name TrkWks -StartupType Disabled

    # Disable Downloaded Maps Manager
    Set-Service-StartupType -Name MapsBroker -StartupType Disabled

    # Disable Geolocation Service
    Set-Service -Name lfsvc -StartupType Disabled

    # Disable Infrared Monitor Service
    Set-Service-StartupType -Name Irmon -StartupType Disabled

    # Disable Print Spooler
    Set-Service-StartupType -Name Spooler -StartupType Disabled

    # Disable Parental Control
    Set-Service-StartupType -Name WPCSvc -StartupType Disabled

    # Disable Windows Update Service
    Set-Service-StartupType -Name wuauserv -StartupType Disabled

    # Disable Windows Image Acquisition
    Set-Service-StartupType -Name stisvc -StartupType Disabled

    # Disable Windows Camera Frame Server
    Set-Service-StartupType -Name FrameServer -StartupType Disabled

    # Disable Windows Insider Service
    Set-Service-StartupType -Name wisvc -StartupType Disabled
}

# Function to remove the scheduled task
Function Remove-ScheduledTask {
    param (
        [string]$taskName
    )
    try {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
        Write-Host "The scheduled task '$taskName' has been removed."
    }
    catch {
        Write-Host "The scheduled task '$taskName' does not exist."
    }
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

# Disable OneDrive Autostart
Disable-OneDriveAutostart -onedrivePath $onedrivePath

# Disable Windows Auto Update
Disable-WindowsAutoUpdate

# Disable cortana
Disable-Cortana

# Disable Windows Defender
Disable-WindowsDefender

# Disable Windows Notifications
Disable-WindowsNotifications

# Disable Windows Services
Disable-Windows-Services

# Remove the scheduled task to prevent further executions
Remove-ScheduledTask -taskName $taskName