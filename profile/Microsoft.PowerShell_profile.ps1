# PowerShell Profile

# devpod ssh command isn't working for me on Windows: https://github.com/loft-sh/devpod/issues/1947
function Ssh-DevPod {
# ssh into a devpod workspace
    param(
        [string]$Path = "."
    )
    try {
        Write-Host "Getting workspace ID..."
        $workspaceId = (devpod status $Path --output json | ConvertFrom-Json).id
        if ($workspaceId) {
	    Write-Host "Executing command: ssh $workspaceId.devpod ..."
            ssh "$workspaceId.devpod"
        } else {
            Write-Host "No workspace found at path: $Path" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error getting workspace: $_" -ForegroundColor Red
    }
}

function Start-Devpod {
    # Start devpod workspace using podman, and ssh into workspace
    param(
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
        Write-Host "Executing command: devpod up $WorkspacePath ..."
        devpod up $WorkspacePath
        Ssh-Devpod $WorkspacePath
    }
    catch {
        Write-Host "Error starting workspace: $_" -ForegroundColor Red
    }
}

# Usage:
# dev                           # Uses current directory
# dev C:\path\to\project        # Uses specified path
# dev ..\other-project          # Uses relative path
Set-Alias -Name dev -Value Start-Devpod

