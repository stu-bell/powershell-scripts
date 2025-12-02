<#
.SYNOPSIS
    Demo of a PowerShell script that waits for user to press any key before exiting

.DESCRIPTION
    Demonstration PowerShell script that waits for user to press any key before the script exits.

.PARAMETER NonInteractive
    Prevents prompts for user input. Inteded for automated execution.

.PARAMETER Text
    The text string to be displayed by the demo script

.NOTES
    Author      : Stuart Bell
    License     : MIT
    Repository  : https://github.com/stu-bell/powershell-snippets

.LINK
    https://github.com/stu-bell/powershell-snippets
#>
param(
 [switch]
 [Parameter(HelpMessage = "Prevents prompts for user input. Inteded for automated execution.")]
 $NonInteractive,

 [string]
 [Parameter(HelpMessage = "Text to be printed")]
 $Text="Hello!"
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

# Check that the arguments are passed through
Write-Host "You entered: $Text"

# Wait before exiting
Wait-ForKey -Message "Press any key to exit..."

