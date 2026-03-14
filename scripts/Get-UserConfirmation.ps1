<#
.NOTES
    RUNNING SCRIPTS CARRIES RISK. ALWAYS REVIEW SCRIPTS BEFORE RUNNING THEM ON YOUR SYSTEM.
    IF IN DOUBT, COPY AND PASTE THE SCRIPT INTO A SERVICE LIKE CHATGPT AND ASK IF IT COULD BE HARMFUL.

.SYNOPSIS
    Demo of a PowerShell script that asks for user confirmation.

.DESCRIPTION
    Demo of a PowerShell script that asks for user confirmation, prints the result, then exits.
    Force switch is supported.

.PARAMETER Force
    Prevents prompts for user input. Inteded for automated execution.

.NOTES
    Author      : Stuart Bell
    License     : MIT
    Repository  : https://github.com/stu-bell/powershell-scripts

.LINK
    https://github.com/stu-bell/powershell-scripts
#>
param(
 [switch]
 [Parameter(HelpMessage = "Prevents prompts for user input. Inteded for automated execution.")]
 $Force
 )

function Get-UserConfirmation {
    # Ask for user confirmation via keyboard, unless -Force switch has been supplied
    # This assumes there is a $Force parameter at script level
    # If calling from another file, use the explicit Force parameter: Get-UserConfirmation -Force:$Force
    param(
	    [string]$ConfirmText="yes",
	    [string]$Message="Type '$ConfirmText' then enter to continue, or enter to cancel",
	    [string]$NoText="Action cancelled by user.",
        [switch]$Force
	)
    # return early if $Force
    if ($script:Force -or $Force) {
        return $True
    }
    # wait for specific key
    $confirm = Read-Host $Message
    if ($confirm -cne $ConfirmText) {
        Write-Host $NoText -ForegroundColor Red
        return $False
    }
    return $True
}

# demo get user confirmation 
Write-Host "Compare running this demo script with and without the -Force parameter."
if (Get-UserConfirmation) {
    Write-Host "User said yes"
} else {
    Write-Host "User said no"
}
Write-Host "Done"
