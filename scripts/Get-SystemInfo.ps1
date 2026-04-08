# View specific OS details
Write-Host "OS info: $(Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber)"
# View OS properties available: (Get-CimInstance Win32_OperatingSystem) | Get-Member -MemberType Properties

# Processor Architecture
Write-Host "Processor architecture: $env:PROCESSOR_ARCHITECTURE"

# View WSL details
wsl.exe --version 2>$null

# Oneliner to output a custom object
[PSCustomObject]@{ OSName = (Get-CimInstance Win32_OperatingSystem).Caption; Version = (Get-CimInstance Win32_OperatingSystem).Version; Build = (Get-CimInstance Win32_OperatingSystem).BuildNumber; Architecture = $env:PROCESSOR_ARCHITECTURE; WSL = (wsl.exe --version 2>$null) }
