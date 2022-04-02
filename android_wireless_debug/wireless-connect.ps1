Write-Host "------------------" -ForegroundColor Yellow
Write-Host "Wireless Debugging" -ForegroundColor Yellow
Write-Host "------------------" -ForegroundColor Yellow

$retry = 0
$phoneip = $null
function GetConnectedDeviceIP() {

    Write-Host "> Checking phone connection..."
    $wlan = D:\SDK\Android\platform-tools\adb.exe shell ifconfig wlan0 
    if ($wlan -match "more than one device") {
        Write-Error "adb already running, please close the process and retry."
    }
    elseif ($wlan -match "no devices\/emulators found") {
        Write-Error "No connected devices found."
    }
    else {
        Write-Host "> Getting Phone IP..."
        $phoneip = $wlan | FINDSTR /I /R /C:"inet addr" | Select-String -Pattern '\d*\.\d*\.\d*\.\d*' | % { $_.Matches } | % { $_.Value }
        Write-Host "> Creating configuration file..."
        if ($phoneip -ne $null) {
            $phoneip | Out-File -FilePath "$($PSScriptRoot)/config.cfg"
            Write-Host "> Configuration file created"
        }
        else {
            Write-Host "Can't get the IP to create configuration file, configuration will not be created."  -ForegroundColor Yellow
        }
    }
    return $phoneip
    
}
function ConnectToAndroid($phoneip) {
    Write-Host "> Phone IP:" $phoneip

    if ($phoneip -eq $null) {
        Write-Error [string]"Can't find Phone IP, connect your Phone or check USB connection."
    }
    else {
        Write-Host "> Setting up port 5555..."
        $port = D:\SDK\Android\platform-tools\adb.exe tcpip 5555
        Write-Host ">" $port
        $connection = D:\SDK\Android\platform-tools\adb.exe connect "$($phoneip):5555"

        if ($connection -match "connected to") {
            Write-Host "> Connected to $($phoneip):5555" -ForegroundColor Green
        }
        else {
            Remove-Item "$($PSScriptRoot)/config.cfg"
            if ($retry -eq 1) { Write-Error "Error during connection to '$($phoneip):5555'" }
            else {
                Write-Host "> Connection to $($phoneip) failed"  -ForegroundColor Yellow
                Write-Host "> Retrying with a different configuration..." -ForegroundColor Yellow
                $retry = 1
                $phoneip = GetConnectedDeviceIP
                ConnectToAndroid($phoneip)
            }
        }
    }
}


Write-Host "> Checking configuration file presence..."
$isConfigPresent = Test-Path -Path "$($PSScriptRoot)/config.cfg" -PathType Leaf
if ($isConfigPresent -eq $false) {
    Write-Host "> Configuration not present"
    $phoneip = GetConnectedDeviceIP
}
else {
    Write-Host "> Configuration present"
    $phoneip = Get-Content -Path "$($PSScriptRoot)/config.cfg"

}

ConnectToAndroid($phoneip)
pause
