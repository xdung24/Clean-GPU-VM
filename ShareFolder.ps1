param (
    [string]$SharedFolder
)

# Check if the script is running as Administrator
Function Is-Administrator {  
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $CurrentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

# Enable file sharing
Function Enable-FileSharing {
    # Turn on network sharing
    Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
    Enable-NetFirewallRule -DisplayGroup "Network Discovery"
    
    # Check if the firewall rule exists
    try {
        $firewallRules = Get-NetFirewallRule
        $rule = $firewallRules | Where-Object { $_.Name -eq "File and Printer Sharing (SMB-In)" }
        if ($rule.Enabled) {
            Write-Output "INFO   : File sharing is already enabled."
            return
        } else {
            Write-Output "ERROR  : File and Printer Sharing (SMB-In) rule not found."
            Write-Output "INFO   : Verify the rule name and ensure it exists on the system."
        }
    } catch {
        Write-Output "ERROR  : File and Printer Sharing (SMB-In) rule not found."
        Write-Output "INFO   : Run the following command to enable file sharing."
        Write-Output "INFO   : Set-NetFirewallRule -Name 'File and Printer Sharing (SMB-In)' -Enabled True"
        return
    }  
}

# Setup shared folder
Function New-ShareFolder {
    param(
        [string]$SharedFolder
    )

    # get last part of SharedFolder
    $SharedFolderName = $SharedFolder -split '\\' | Select-Object -Last 1
    $permissions = "Full"
    $account = "Everyone"

    # Create the folder if it doesn't exist
    if (-Not (Test-Path -Path $SharedFolder)) {
        New-Item -ItemType Directory -Path $SharedFolder
        Write-Output "INFO   : Folder '$SharedFolder' created successfully."
    }

    # Check if the name is already shared
    $shared = Get-SmbShare | Where-Object { $_.Name -eq $SharedFolderName }
    if ($shared) {
        Write-Output "INFO   : Folder '$SharedFolder' is already shared."
        return
    }

    # Share the folder
    try {
        New-SmbShare -Name $SharedFolderName -Path $SharedFolder -FullAccess $account
        Write-Output "INFO   : Shared folder '$SharedFolder' successfully."
    }
    catch {
        Write-Output "ERROR  : Failed to create SMB share. $_"
    }

    try {
        Grant-SmbShareAccess -Name $SharedFolderName -AccountName $account -AccessRight $permissions -Force
        Write-Output "INFO   : Everyone access folder '$SharedFolder' granted successfully."    
    }
    catch {
        Write-Output "ERROR  : Failed to grant Everyone access. $_"
    }

    # Set the shared folder permissions
    try {
        $acl = Get-Acl -Path $SharedFolder
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($account, $permissions, "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.SetAccessRule($accessRule)
        Set-Acl -Path $SharedFolder -AclObject $acl
        Write-Output "INFO   : Permissions set for shared folder '$SharedFolder'."
    }
    catch {
        Write-Output "ERROR  : Failed to set permissions. $_"
    }
}

Function SmartExit {
    param (
        [switch]$NoHalt,
        [string]$ExitReason
    )
    if (($host.name -eq 'Windows PowerShell ISE Host') -or ($host.Name -eq 'Visual Studio Code Host')) {
        Write-Host $ExitReason
        Exit
    }
    else {
        if ($NoHalt) {
            Write-Host $ExitReason
            Exit
        }
        else {
            Write-Host $ExitReason
            Read-host -Prompt "Press any key to Exit..."
            Exit
        }
    }
}

# Main script
$arguments = $PSBoundParameters
# Default values
$params = @{
    SharedFolder = "C:\VmShareData"
}

# Overwrite default values with provided parameters
foreach ($key in $arguments.Keys) {
    $params[$key] = $arguments[$key]
}

# Print all arguments
foreach ($key in $params.Keys) {
    Write-Host "INFO   : $key = $($params[$key])"
}

# Check if the script is running as Administrator
if (-Not (Is-Administrator)) {
    Write-Output "ERROR  : Please run this script as Administrator."
    SmartExit -NoHalt
}

# Enable FileSharing
Enable-FileSharing

# Call the function with the updated parameters
New-ShareFolder e -SharedFolder $params.SharedFolder

$exitReason = @"

### Steps to Map Network Drive in Guest OS:
1. **Start the Virtual Machine**: Ensure the VM is running.
2. **Login to the Guest OS**: Use Remote Desktop or Hyper-V Manager to access the VM.
3. **Map Network Drive**: Use the following command in the guest OS to map the network drive.

```powershell
# In the guest OS
net use Z: \\NetworkPath\SharedFolder /user:username password
```

Replace `\\NetworkPath\SharedFolder` with the actual network path, 
and 'username' and 'password' with the appropriate credentials.
"@
SmartExit -ExitReason $exitReason