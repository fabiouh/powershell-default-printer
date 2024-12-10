$configPath = "./config.json"

if (-Not (Test-Path -Path $configPath)) {
    Write-Host "Config file not found: $configPath" -ForegroundColor Red
    Exit 1
}

$config = Get-Content -Path $configPath | ConvertFrom-Json

function Get-NetworkName {
    # Get current wifi ssid name
    try {
        $wifi = netsh wlkan show interfaces | Select-String -Pattern "SSID\s+:\s+(.*)" | ForEach-Object { $_.Matches[0].Groups[1].Value }

        if($wifi) {
            return $wifi
        }
    } catch {
        Write-Host "Not connected to wifi" -ForegroundColor Yellow
    }

    # Get current ethernet subnet
    try {
        $ipConfig = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch "Loopback" }

        if($ipConfig) {
            return ($ipConfig.IPAddress -replace "\.\d+$") # return subnet
        }
    } catch {
        Write-Host "Not connected to ethernet"- ForegroundColor Yellow
    }

    return $null
}

$activeNetwork = Get-NetworkName

if(-Not $activeNetwork) {
    Write-Host "No active network found" -ForegroundColor Yellow
    Exit 0
}

$matchedPrinter = $config.Networks | Where-Object { $activeNetwork -like "$($_.NetworkName)*" } | Select-Object -ExpandProperty Printer -ErrorAction SilentlyContinue
$fallbackPrinter = $config.FallbackPrinter

if(-Not $matchedPrinter) {
    Write-Host "No printer found for network: $activeNetwork, setting fallback printer: $fallbackPrinter" -ForegroundColor Yellow
    $matchedPrinter = $fallbackPrinter
}

if($matchedPrinter) {
    try {
        (Get-Printer -Name $matchedPrinter | Set-Printer -Default)
        Write-Host "Default printer set to: $matchedPrinter"- ForegroundColor Green
        Exit 0
    } catch {
        Write-Host "Error setting default printer '$matchedPrinter': $_" -ForegroundColor Red
        Exit 1
    }
} else {
    Write-Host "No printer found for network: $activeNetwork and no fallback printer set" -ForegroundColor Red
    Exit 1
}

