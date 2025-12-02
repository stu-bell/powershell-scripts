<#
.SYNOPSIS
    HTTP file server. Serves current working directory to the local network.

.DESCRIPTION
    HTTP file server. Serves current working directory to the local network.
    Can be used to send files to devices with limited connectivity, eg e-readers, as long as they have a web browser.

    This script updates your firewall rules, unless you're using the -localhost option
    Firewall rule is added to allow inbound requests to the port
    To review firewall rules:
    Get-NetFirewallRule | Where-Object { $_.DisplayName -like "LocalHTTPServerPowershell*" }
    To remove firewall rule once done:
    Get-NetFirewallRule | Where-Object { $_.DisplayName -like "LocalHTTPServerPowershell*" } | Remove-NetFirewallRule

.PARAMETER port
    Port number to use

.PARAMETER localhost
    This option only serves to localhost and not the local network. No changes to firewall rules.

.PARAMETER stoproute
    Optional route to stop the server from the client. Eg if stoproute=STOP, navigating to http://<ipaddress>:<port>/STOP will stop the server

.NOTES
    Author: github.com/stu-bell
    Date: 2025-01-14
    Version: 0.4
#>

#Requires -RunAsAdministrator
# To run as admin: https://learn.microsoft.com/en-us/windows/terminal/faq#how-do-i-run-a-shell-in-windows-terminal-in-administrator-mode
# Set-ExecutionPolicy -Scope CurrentUser Unrestricted

param(
    [Parameter(HelpMessage="Port number to use")]
    [int]$port = 8000,
    [Parameter(HelpMessage="Use localhost instead of serving on the local network")]
    [switch]$localhost = $false,
    [Parameter(HelpMessage="Optional route to stop the server")]
    [string]$stoproute
)

if ($localhost) {
    $localIP = "localhost"
} else {
    # Get host's IP address
    $localIP = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -like "192.168.*" } |
    Select-Object -ExpandProperty IPAddress -First 1

    # Open the port for local network only
    $ruleName = "LocalHTTPServerPowershell" 
    Write-Host "Adding firewall rule $ruleName"
    $null = New-NetFirewallRule -LocalPort ${port} -DisplayName $ruleName -Direction Inbound -Protocol TCP -LocalAddress $localIP -RemoteAddress 192.168.1.0/24 -Action Allow
}

# set up a drive for the root directory
$Root = $PWD.Path
$null = New-PSDrive -Name FileServer -PSProvider FileSystem -Root $Root

# needed for MIME types
$null = [System.Reflection.Assembly]::LoadWithPartialName("System.Web")

# Create and start listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://${localIP}:${port}/")
$listener.Start()

Write-Host "Server running: http://${localIP}:${port}"

# Route to stop server remotely
if ($PSBoundParameters.ContainsKey('stoproute')) {
    $stoproute = if ($stoproute[0] -ne '/') {'/' + $stoproute } else { $stoproute }
    Write-Host "Stop server at: http://${localIP}:${port}${stoproute}"
}

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $response = $context.Response
        $localPath = $context.Request.Url.LocalPath

        Write-Host "> $($context.Request.Url) from $($context.Request.RemoteEndPoint)"
        
        try {
            # Could handle auth here
            # https://learn.microsoft.com/en-us/dotnet/api/system.net.httplistenerrequest
            
            # URL path to stop the server
            if ($PSBoundParameters.ContainsKey('stoproute') -and $context.Request.Url.LocalPath -eq $stoproute) {
                Write-Host "Stop request received"
                break
            }

            # directory or file route
            $RequestedItem = Get-Item -LiteralPath "FileServer:\$localPath" -Force -ErrorAction Stop
            if ($RequestedItem.Attributes -match "Directory") {
                # Return HTML list of directory contents
                $files = Get-ChildItem $RequestedItem.FullName
                $html = "<html><body><h1>Directory: $localPath</h1><ul>"
                foreach ($file in $files) {
                    $name = $file.Name
                    $html += "<li><a href=`"$($localPath.TrimEnd('/'))/$name`">$name</a></li>"
                }
                $html += "</ul></body></html>"
                $content = [System.Text.Encoding]::UTF8.GetBytes($html)
                $response.ContentType = "text/html"
            } else {
                # Serve the file
                $content = [System.IO.File]::ReadAllBytes($RequestedItem.FullName)
                $response.ContentType = [System.Web.MimeMapping]::GetMimeMapping($RequestedItem.FullName)
            }

            # write response
            $response.StatusCode = 200
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
            $response.Close()
            Write-Host "< $($response.StatusCode)"

        } catch [System.Management.Automation.ItemNotFoundException] {
            # RequestedItem not found
            $content = [System.Text.Encoding]::UTF8.GetBytes("<h1>404 - Not Found</h1>")
            $response.StatusCode = 404
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
            $response.Close()
            Write-Host "< $($response.StatusCode)"
        } catch {
            Write-Host "An error occurred: $_"
        }
    }
} finally {
    $listener.Stop()
    Remove-PSDrive FileServer
    if (-not $localhost) {
        Remove-NetFirewallRule -DisplayName $ruleName
    }
    Write-Host "`nServer stopped"
}
