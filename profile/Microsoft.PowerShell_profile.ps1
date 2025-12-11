# PowerShell Profile

# ssh into a devpod workspace
# devpod ssh command isn't working for me on Windows: https://github.com/loft-sh/devpod/issues/1947
function Ssh-DevPod {
    param(
        [string]$Path = "."
    )

    try {
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

# Usage:
# shd                           # Uses current directory
# shd C:\path\to\project        # Uses specified path
# shd ..\other-project          # Uses relative path
Set-Alias -Name shd -Value Ssh-DevPod

