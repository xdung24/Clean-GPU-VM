﻿param(
$team_id,
$key
)


# Hangs the script until the network is available
while(!(Test-NetConnection Google.com).PingSucceeded){
  Start-Sleep -Seconds 1
}


# Download the Easy-GPU-P package
Get-ChildItem -Path C:\ProgramData\Easy-GPU-P -Recurse | Unblock-File


# Install Sunshine
(New-Object System.Net.WebClient).DownloadFile("https://github.com/LizardByte/Sunshine/releases/download/v0.23.1/sunshine-windows-installer.exe", "C:\Users\$env:USERNAME\Downloads\sunshine-windows-installer.exe")
Start-Process "C:\Users\$env:USERNAME\Downloads\sunshine-windows-installer.exe" -ArgumentList "/S" -wait


# Function for installing VB Cable
Function VBCableInstallSetupScheduledTask {
$XML = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Install VB Cable</Description>
    <URI>\Install VB Cable</URI>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <UserId>$(([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name)</UserId>
      <Delay>PT2M</Delay>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$(([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value)</UserId>
      <LogonType>S4U</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe</Command>
      <Arguments>-file %programdata%\Easy-GPU-P\VBCableInstall.ps1</Arguments>
    </Exec>
  </Actions>
</Task>
"@

  try {
      Get-ScheduledTask -TaskName "Install VB Cable" -ErrorAction Stop | Out-Null
      Unregister-ScheduledTask -TaskName "Install VB Cable" -Confirm:$false
      }
  catch {}
  $action = New-ScheduledTaskAction -Execute 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-file %programdata%\Easy-GPU-P\VBCableInstall.ps1'
  $trigger =  New-ScheduledTaskTrigger -AtStartup
  Register-ScheduledTask -XML $XML -TaskName "Install VB Cable" | Out-Null
}


# Function for Virtual Display Driver
Function VirtualDisplayDriverInstallSetupScheduledTask {
$XML = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Install VirtualDisplayDriver</Description>
    <URI>\Install VirtualDisplayDriver</URI>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <UserId>$(([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name)</UserId>
      <Delay>PT2M</Delay>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$(([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value)</UserId>
      <LogonType>S4U</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe</Command>
      <Arguments>-file %programdata%\Easy-GPU-P\VirtualDisplayDriverInstall.ps1</Arguments>
    </Exec>
  </Actions>
</Task>
"@

  try {
      Get-ScheduledTask -TaskName "Install VirtualDisplayDriver" -ErrorAction Stop | Out-Null
      Unregister-ScheduledTask -TaskName "Install VirtualDisplayDriver" -Confirm:$false
  } catch {}
  $action = New-ScheduledTaskAction -Execute 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-file %programdata%\Easy-GPU-P\VirtualDisplayDriverInstall.ps1'
  $trigger =  New-ScheduledTaskTrigger -AtStartup
  Register-ScheduledTask -XML $XML -TaskName "Install VirtualDisplayDriver" | Out-Null
}


# Function for disabling Windows Features
Function DisableWindowsFeaturesScheduledTask {
    $XML = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Disable Window Features</Description>
    <URI>\DisableWindowFeatures</URI>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <UserId>$(([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name)</UserId>
      <Delay>PT2M</Delay>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$(([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value)</UserId>
      <LogonType>S4U</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe</Command>
      <Arguments>-file %programdata%\Easy-GPU-P\DisableWindowFeatures.ps1</Arguments>
    </Exec>
  </Actions>
</Task>
"@

  try {
      Get-ScheduledTask -TaskName "DisableWindowFeatures" -ErrorAction Stop | Out-Null
      Unregister-ScheduledTask -TaskName "DisableWindowFeatures" -Confirm:$false
  } catch {}
  $action = New-ScheduledTaskAction -Execute 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-file %programdata%\Easy-GPU-P\DisableWindowFeatures.ps1'
  $trigger =  New-ScheduledTaskTrigger -AtStartup
  Register-ScheduledTask -XML $XML -TaskName "DisableWindowFeatures" | Out-Null
}


# Function to create shared folder
Function CreateSharedFolderScheduledTask {
  $XML = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
<RegistrationInfo>
  <Description>Create Shared Folder</Description>
  <URI>\CreateSharedFolder</URI>
</RegistrationInfo>
<Triggers>
  <LogonTrigger>
    <Enabled>true</Enabled>
    <UserId>$(([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name)</UserId>
    <Delay>PT2M</Delay>
  </LogonTrigger>
</Triggers>
<Principals>
  <Principal id="Author">
    <UserId>$(([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value)</UserId>
    <LogonType>S4U</LogonType>
    <RunLevel>HighestAvailable</RunLevel>
  </Principal>
</Principals>
<Settings>
  <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
  <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
  <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
  <AllowHardTerminate>true</AllowHardTerminate>
  <StartWhenAvailable>false</StartWhenAvailable>
  <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
  <IdleSettings>
    <StopOnIdleEnd>true</StopOnIdleEnd>
    <RestartOnIdle>false</RestartOnIdle>
  </IdleSettings>
  <AllowStartOnDemand>true</AllowStartOnDemand>
  <Enabled>true</Enabled>
  <Hidden>false</Hidden>
  <RunOnlyIfIdle>false</RunOnlyIfIdle>
  <WakeToRun>false</WakeToRun>
  <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
  <Priority>7</Priority>
</Settings>
<Actions Context="Author">
  <Exec>
    <Command>C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe</Command>
    <Arguments>-file %programdata%\Easy-GPU-P\CreateSharedFolder.ps1</Arguments>
  </Exec>
</Actions>
</Task>
"@

  try {
      Get-ScheduledTask -TaskName "CreateSharedFolder" -ErrorAction Stop | Out-Null
      Unregister-ScheduledTask -TaskName "CreateSharedFolder" -Confirm:$false
  } catch {}
  $action = New-ScheduledTaskAction -Execute 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-file %programdata%\Easy-GPU-P\CreateSharedFolder.ps1'
  $trigger =  New-ScheduledTaskTrigger -AtStartup
  Register-ScheduledTask -XML $XML -TaskName "CreateSharedFolder" | Out-Null
}

# Function to remove the logon script entry
Function Remove-LogonScript {
  $scriptPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logon\0"
  if (Test-Path $scriptPath) {
      Remove-Item $scriptPath -Recurse -Force
  }
}

# Create schedule tasks
VBCableInstallSetupScheduledTask
VirtualDisplayDriverInstallSetupScheduledTask
DisableWindowsFeaturesScheduledTask
CreateSharedFolderScheduledTask


# Start the scheduled tasks
Start-ScheduledTask -TaskName "Install VB Cable"
Start-ScheduledTask -TaskName "Install VirtualDisplayDriver"
Start-ScheduledTask -TaskName "DisableWindowFeatures"


# Set the "Turn off the display" parameter to never
powercfg.exe /change monitor-timeout-ac 0

# Remove the logon script entry to prevent further executions
Remove-LogonScript
