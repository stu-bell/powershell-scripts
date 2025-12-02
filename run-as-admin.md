For more on how run a script as admin: [Run a shell in Windows Terminal in administrator mode](https://learn.microsoft.com/en-us/windows/terminal/faq#how-do-i-run-a-shell-in-windows-terminal-in-administrator-mode)

# Make a script automatically request admin elevation

To write a script that automatically prompts the user for administrator privileges, add this snippet at the start of the script (see [Request-Admin.ps1](./scripts/Request-Admin.ps1) for a demo): 

```
# Check if script is running as Administrator, and request elevation if not
# Reruns the command from the beginning, passing through the original arguments
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host -ForegroundColor Red "This script must be run as Administrator. Requesting..."
    $params = ($PSBoundParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) `"$($_.Value -replace '"','""')`"" }) -join ' '
   $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $params"
    Start-Process powershell -ArgumentList $argList -Verb RunAs
    exit
}
```
> Note this is not compatible with `#Requires -RunAsAdministrator` (see below).

# #Requires -RunAsAdministrator

To prevent the script running unless it is running with administrator privileges, write a `#Requires -RunAsAdministrator` comment at the top of your script. This will cause an error if the script is run without administrator privileges. 

