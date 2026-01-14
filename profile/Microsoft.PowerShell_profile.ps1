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
        # need to check devpod status before attempting ssh, as ssh when devpod is down triggers devpod up, but hangs
        Write-Host "Checking Devpod status..." 
        $devpodStatus = (devpod status $WorkspacePath --output json 2>$null | ConvertFrom-Json)
        if ($LASTEXITCODE -ne 0) {
            # Start podman, devpod and retry ssh
            Write-Host "Starting podman machine..."
            podman machine start
            Write-Host "Starting devpod workspace..."
            devpod up $WorkspacePath
            $devpodStatus = (devpod status $WorkspacePath --output json | ConvertFrom-Json) # needed for new workspaces
            Write-Host "ssh $($devpodStatus.id).devpod ..."
            ssh "$($devpodStatus.id).devpod"
            Write-Host "SSH session ended but devpod still running..."
            return # job done, return early
        }

        # start devpod if needed
        if ($devpodStatus.state -eq "Stopped") {
            Write-Host "devpod up $WorkspacePath ..."
            devpod up $WorkspacePath
        } elseif ($devpodStatus.state -eq "NotFound") {
            Write-Host "devpod up $WorkspacePath ..."
            devpod up $WorkspacePath
            $devpodStatus = (devpod status $WorkspacePath --output json | ConvertFrom-Json) # needed for new workspaces
        } else {
            Write-Host "Devpod status: $($devpodStatus.state)"
        }

        Write-Host "ssh $($devpodStatus.id).devpod ..."
        ssh "$($devpodStatus.id).devpod"
        Write-Host "SSH session ended but devpod still running..."
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

