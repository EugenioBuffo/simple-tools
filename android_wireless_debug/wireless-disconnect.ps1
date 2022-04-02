Write-Host "------------------" -ForegroundColor Yellow
Write-Host "Wireless Debugging" -ForegroundColor Yellow
Write-Host "------------------" -ForegroundColor Yellow

$retry = 0
$phoneip = $null
function GetDisconnectedDeviceIP() {

    Write-Host "> Getting Phone IP from Config..."
    Write-Host "> Creating configuration file..."
    if ($phoneip -ne $null) {
        $phoneip | Out-File -FilePath "$($PSScriptRoot)/config.cfg"
        Write-Host "> Configuration file created"
    }
    else {
        Write-Host "Can't get the IP to create configuration file, configuration will not be created."  -ForegroundColor Yellow
    }
    return $phoneip
    
}
function DisconnectFromAndroid($phoneip) {
    Write-Host "> Phone IP:" $phoneip

    if ($phoneip -eq $null) {
        Write-Error [string]"Can't find correct Phone IP in configuration."
    }
    else {
        Write-Host "> Setting up port 5555..."
        $port = D:\SDK\Android\platform-tools\adb.exe tcpip 5555
        Write-Host ">" $port
        $disconnection = D:\SDK\Android\platform-tools\adb.exe disconnect "$($phoneip):5555"

        if ($disconnection -match "disconnected") {
            Write-Host "> Disconnected from $($phoneip):5555" -ForegroundColor Green
        }
        else {
            Write-Host "> Error during disconnection to '$($phoneip):5555'" -ForegroundColor Red
        }
    }
}


Write-Host "> Checking configuration file presence..."
$isConfigPresent = Test-Path -Path "$($PSScriptRoot)/config.cfg" -PathType Leaf
if ($isConfigPresent -eq $false) {
    Write-Host "> Configuration not present, can't disconnect from an unknown device" -ForegroundColor Red
    #$phoneip = GetDisconnectedDeviceIP
}
else {
    Write-Host "> Configuration present..."
    $phoneip = Get-Content -Path "$($PSScriptRoot)/config.cfg"

}

DisconnectFromAndroid($phoneip)
pause
