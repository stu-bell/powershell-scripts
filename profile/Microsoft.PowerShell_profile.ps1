<#
.NOTES
	RUNNING SCRIPTS CARRIES RISK. ALWAYS REVIEW SCRIPTS BEFORE RUNNING THEM ON YOUR SYSTEM.
	IF IN DOUBT, COPY AND PASTE THE SCRIPT INTO A SERVICE LIKE CHATGPT AND ASK IF IT COULD BE HARMFUL.

.SYNOPSIS
    Powershell profile

.DESCRIPTION

.NOTES
	Author      : Stuart Bell
	License     : MIT
	Repository  : https://github.com/stu-bell/powershell-scripts

.LINK
	https://github.com/stu-bell/powershell-scripts
#>
function Start-DevpodWorkspace {
    # Start devpod workspace using podman, and ssh into workspace
    param(
        [Parameter(HelpMessage="Path to Devpod Workspace")]
        [string]$WorkspacePath = "."
    )
    try {
        Write-Host "Checking podman machine status..."
        $podmanStatus = (podman machine info -f json | ConvertFrom-Json).Host.MachineState
        if ($podmanStatus -eq "Stopped") {
            Write-Host "Starting podman machine..."
            podman machine start
        } else {
            Write-Host "Podman machine status: $podmanStatus"
        }

        Write-Host "Checking Devpod status..."
        $devpodStatus = (devpod status $WorkspacePath --output json | ConvertFrom-Json)
        if ($devpodStatus.state -eq "Stopped") {
            Write-Host "Executing command: devpod up $WorkspacePath ..."
            devpod up $WorkspacePath
        } elseif ($devpodStatus.state -eq "NotFound") {
            Write-Host "Executing command: devpod up $WorkspacePath ..."
            devpod up $WorkspacePath
            # NotFound => first time, need to get status again for the ID
            $devpodStatus = (devpod status $WorkspacePath --output json | ConvertFrom-Json)
        } else {
            Write-Host "Devpod status: $($devpodStatus.state)"
        }

        Write-Host "Executing command: ssh $($devpodStatus.id).devpod ..."
        ssh "$($devpodStatus.id).devpod"
    }
    catch {
        Write-Host "Error starting workspace: $_" -ForegroundColor Red
    }
}

# Usage:
# dev                           # Uses current directory
# dev C:\path\to\project        # Uses specified path
# dev ..\other-project          # Uses relative path
Set-Alias -Name dev -Value Start-DevpodWorkspace

