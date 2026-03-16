<#
.NOTES
    RUNNING SCRIPTS CARRIES RISK. ALWAYS REVIEW SCRIPTS BEFORE RUNNING THEM ON YOUR SYSTEM.
    IF IN DOUBT, COPY AND PASTE THE SCRIPT INTO A SERVICE LIKE CHATGPT AND ASK IF IT COULD BE HARMFUL.

.SYNOPSIS
    Demo help text for scripts

.DESCRIPTION
    Demo help text for scripts

.NOTES
    Author      : Stuart Bell
    License     : MIT
    Repository  : https://github.com/stu-bell/powershell-scripts
    Inspired by : Thibaut's answer to https://learn.microsoft.com/en-us/answers/questions/2339429/marvell-avastar-wireless-ac-network-controller-alw

.LINK
    https://github.com/stu-bell/powershell-scripts
#>

param(
	[switch]$OptionA,
	[switch]$OptionB,
	[string]$InputText="hi",
	[switch]$Help
)

function Show-Help {
    Write-Host @"
$($script:MyInvocation.MyCommand.Name)

Demo script for showing help for different switches.

For doc comment, use -? switch: $($script:MyInvocation.MyCommand.Name) -?

See also: Get-Help .\$($script:MyInvocation.MyCommand.Name) -detailed

Run this script with -Help switch and any of the other parameters.

PARAMETERS:
	-Help		Include -Help switch alongside other switches
				to show help for specific switches,
				eg: $($script:MyInvocation.MyCommand.Name) -Help -OptionA
	-OptionA	Use OptionA
	-OptionB	Use OptionB
	-InputText	Text parameter

"@
}

# $PSBoundParameters is an object of options provided by the user
# Show help based on parameters provided
if ($Help -or $PSBoundParameters.Count -eq 0) {
	if ($PSBoundParameters.ContainsKey('InputText')) {
	    Write-Host @"
InputText help text...

"@
	}
	if ($OptionA) {
	    Write-Host @"
OptionA help text...

"@
	}
	if ($OptionB) {
	    Write-Host @"
OptionB help text...

"@
	}
# Show generic help message after specific command messages
	Show-Help
	exit
}
