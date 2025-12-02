<#
.NOTES
    RUNNING SCRIPTS CARRIES RISK. ALWAYS REVIEW SCRIPTS BEFORE RUNNING THEM ON YOUR SYSTEM.
    IF IN DOUBT, COPY AND PASTE THE SCRIPT INTO A SERVICE LIKE CHATGPT AND ASK IF IT COULD BE HARMFUL.

.SYNOPSIS
    Demo of a PowerShell script requesting Administrator privileges

.DESCRIPTION
    Demonstration PowerShell snippet that checks if the process is running with Administrator privileges, and if not, restarts itself requesting Administrator privileges, and passes through the original arguments
    Note this only works with scripts that don't use the `#Requires -RunAsAdministrator` directive.

.PARAMETER Text
    The text string to be displayed by the demo script

.NOTES
    Author      : Stuart Bell
    License     : MIT
    Repository  : https://github.com/stu-bell/powershell-scripts

.LINK
    https://github.com/stu-bell/powershell-scripts
#>
param(
    [string]
    [Parameter(Mandatory=$true,HelpMessage = "Text to be printed")]
    $Text
)


# Display whether the current script is running as admin
$IsAdmin = (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
Write-Host "Is Admin: $IsAdmin"
Write-Host "Working directory: $PWD"


# Demo usage:

# Check if script is running as Administrator, and request elevation if not
# Reruns the command from the beginning, passing through the original arguments
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host -ForegroundColor Red "This script must be run as Administrator. Requesting..."
    $params = ($PSBoundParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) `"$($_.Value -replace '"','""')`"" }) -join ' '
    $currentDir = (Get-Location).Path
    $argList = "-NoProfile -ExecutionPolicy Bypass -Command `"Set-Location '$currentDir'; & '$PSCommandPath' $params`""
    Start-Process powershell -ArgumentList $argList -Verb RunAs 
    exit
}

# Check that the arguments are passed through
Write-Host "You entered: $Text"
# Wait before exiting
Write-Host "Press any key to exit..."
[void][System.Console]::ReadKey($true)
