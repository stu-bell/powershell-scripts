<#
.NOTES
    RUNNING SCRIPTS CARRIES RISK. ALWAYS REVIEW SCRIPTS BEFORE RUNNING THEM ON YOUR SYSTEM.
    IF IN DOUBT, COPY AND PASTE THE SCRIPT INTO A SERVICE LIKE CHATGPT AND ASK IF IT COULD BE HARMFUL.

.SYNOPSIS
    Demo of a PowerShell script that asks for user confirmation.

.DESCRIPTION
    Demo of a PowerShell script that asks for user confirmation, prints the result, then exits.
    NonInteractive switch is supported.

.PARAMETER NonInteractive
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
 $NonInteractive
 )

function Get-UserConfirmation {
    # Ask for user confirmation via keyboard, unless -Skip switch has been supplied
    # Pass variable value to Skip flag (eg parent script contains a -NonInteractive switch):
    # Get-UserConfirmation -Skip:$NonInteractive
    # Or, set the default value of $Skip to a script paremeter, or use $PSDefaultParameterValues
    param(
        [switch]$Skip=$script:NonInteractive,
	    [string]$ConfirmText="yes",
	    [string]$Message="Type '$ConfirmText' then enter to continue, or enter to cancel",
	    [string]$NoText="Action cancelled by user."
	)
    # return early if $Skip
    if ($Skip) {
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
Write-Host "Compare running this demo script with and without the -NonInteractive parameter."
if (Get-UserConfirmation) {
    Write-Host "User said yes"
} else {
    Write-Host "User said no"
}
Write-Host "Done"
