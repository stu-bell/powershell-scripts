<#
.SYNOPSIS
Restarts a specific device in Windows Device Manager.
Requires Administrator Privileges.

.DESCRIPTION
Locates a device by its friendly name, disables and re-enables it to
perform a soft restart, and reports the result.

.PARAMETER DeviceName
Name of the device to restart, as shown in Device Manager.

.PARAMETER NonInteractive
Prevents prompts for user input. Inteded for automated execution.

.NOTES
    Author      : Stuart Bell
    License     : MIT
    Repository  : https://github.com/stu-bell/powershell-snippets
    Inspired by : Thibaut's answer to https://learn.microsoft.com/en-us/answers/questions/2339429/marvell-avastar-wireless-ac-network-controller-alw

.LINK
    https://github.com/stu-bell/powershell-snippets
#>
param(
 [string]
 [Parameter(HelpMessage = "Name of the device to restart, as it appears in Device Manager.")]
 $DeviceName = "Marvell AVASTAR Wireless-AC Network Controller",

 [switch]
 [Parameter(HelpMessage = "Prevents prompts for user input. Inteded for automated execution.")]
 $NonInteractive
)

# Waits for user input before continuing, unless script paramter $NonInteractive is true
function Wait-ForKey {
    param (
        [string]$Message = "Press any key to continue..."
    )
    if (-not $Global:NonInteractive) {
        Write-Host $Message
        [void][System.Console]::ReadKey($true)
    }
}

# Check if script is running as Administrator, and request elevation if not
# Reruns the command from the beginning, passing through the original arguments
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host -ForegroundColor Red "This script must be run as Administrator. Requesting..."
    $params = ($PSBoundParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) `"$($_.Value -replace '"','""')`"" }) -join ' '
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $params"
    Start-Process powershell -ArgumentList $argList -Verb RunAs
    exit
}

# Find the device
$device = Get-PnpDevice | Where-Object { $_.FriendlyName -eq $DeviceName }
if ($null -eq $device) {
    Write-Host "Device '$DeviceName' not found." -ForegroundColor Red
}

Write-Host " Disabling device: $($device.FriendlyName)..."
Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false

Start-Sleep -Seconds 2  # Wait briefly before re-enabling

Write-Host "Restarting device: $($device.FriendlyName)..."
Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
Write-Host "Done restarting device"

Wait-ForKey

