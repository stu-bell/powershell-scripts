<#
.NOTES
	RUNNING SCRIPTS CARRIES RISK. ALWAYS REVIEW SCRIPTS BEFORE RUNNING THEM ON YOUR SYSTEM.
	IF IN DOUBT, COPY AND PASTE THE SCRIPT INTO A SERVICE LIKE CHATGPT AND ASK IF IT COULD BE HARMFUL.

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

.PARAMETER DirectoryPath
    Directory to serve. Defaults to current working directory

.PARAMETER Port
    Port number to use

.PARAMETER HostOnNet
    Host to your network, not just localhost

.PARAMETER StopRoute
    Optional route to stop the server from the client. Eg if StopRoute=STOP, navigating to http://<ipaddress>:<port>/STOP will stop the server

.NOTES
	Author      : Stuart Bell
	License     : MIT
	Repository  : https://github.com/stu-bell/powershell-scripts

.LINK
	https://github.com/stu-bell/powershell-scripts
#>

param(
    [Parameter(HelpMessage="Directory to serve")]
    [string]$DirectoryPath=".",
    [Parameter(HelpMessage="Port number to use")]
    [int]$Port = 8000,
    [Parameter(HelpMessage="Serve on your network. Otherwise just serve on localhost")]
    [switch]$HostOnNet = $false,
    [Parameter(HelpMessage="Optional route to stop the server")]
    [string]$StopRoute
)

# resolve relative file paths
$DirectoryPath = (Resolve-Path $DirectoryPath).Path

if ($HostOnNet) {
# Check we have admin
    $IsAdmin = (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    if (-not $IsAdmin){
        Write-Error "Error: to use option -HostOnNet, script must be run as administrator."
        exit
    }

    # Get host's IP address
    $localIP = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -like "192.168.*" } |
    Select-Object -ExpandProperty IPAddress -First 1

    # Open the port for local network only
    $ruleName = "LocalHTTPServerPowershell" 
    Write-Host "Adding firewall rule $ruleName"
    $null = New-NetFirewallRule -LocalPort ${Port} -DisplayName $ruleName -Direction Inbound -Protocol TCP -LocalAddress $localIP -RemoteAddress 192.168.1.0/24 -Action Allow
} else {
    $localIP = "localhost"
}

# set up a drive for the root directory
$Root = $DirectoryPath
$null = New-PSDrive -Name FileServer -PSProvider FileSystem -Root $Root

# needed for MIME types
$null = [System.Reflection.Assembly]::LoadWithPartialName("System.Web")

# Create and start listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://${localIP}:${Port}/")
$listener.Start()

Write-Host "Server running: http://${localIP}:${Port}"

# Route to stop server remotely
if ($PSBoundParameters.ContainsKey('StopRoute')) {
    $StopRoute = if ($StopRoute[0] -ne '/') {'/' + $StopRoute } else { $StopRoute }
    Write-Host "Stop server at: http://${localIP}:${Port}${StopRoute}"
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
            if ($PSBoundParameters.ContainsKey('StopRoute') -and $context.Request.Url.LocalPath -eq $StopRoute) {
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
    if ($HostOnNet) {
        Remove-NetFirewallRule -DisplayName $ruleName
    }
    Write-Host "`nServer stopped"
}
