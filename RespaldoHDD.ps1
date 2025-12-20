########################################################################
##                             EDITAR                                 ##
##--------------------------------------------------------------------##
$Disk_Origin = "Z" # Unidad a respaldar                               ##
$Disk_Destiny = "Z" # Unidad donde ira el respaldo                    ##
$DU_exe = "Z:\SysinternalsSuite\du.exe" # Ejecutable de Disk Usage    ##
                                        #   (Sysinternals Suite)      ##

################ Tests ################ 
$ruta_Respaldo = "$(Get-Location)\TESTS-Respaldar-PortableHDD\RespaldoHDD"
$rutas_Origen = @(
    "$(Get-Location)\TESTS-Respaldar-PortableHDD\Test1",
    "$(Get-Location)\TESTS-Respaldar-PortableHDD\Test2"
)

# $ruta_Respaldo = "${Disk_Destiny}:\RespaldoHDD"
# $rutas_Origen = @(
#   "${Disk_Origin}:\Carpeta-Gigante-1",
#   "${Disk_Origin}:\Carpeta-Gigante-2"
# )

# Verificar que existen los directorios de origen
foreach ($ruta in $rutas_Origen) {
  if (-not (Test-Path $ruta)) {
    Write-Warning "The route $ruta doesn't exist"
    return
  }
}

# Eliminar el respaldo anterior en caso de que exista
if (Test-Path $ruta_Respaldo) {
  Remove-Item $ruta_Respaldo -Recurse -Force
}

# Cantidad de archivos de directorios originales
Write-Host "Counting files from Origin..."
Write-Host ""
$files_original = 0
forEach ($ruta in $rutas_Origen) {
  if (Test-Path $ruta) {
    # Enumerator para no cargar todo en memoria
    $enumerator = [System.IO.Directory]::EnumerateFiles($ruta, "*", [System.IO.SearchOption]::AllDirectories)
        
    forEach ($file in $enumerator) {
      $files_original++
    }
  }
}

# Crear directorio de respaldo
New-Item -Path $ruta_Respaldo -ItemType Directory -Force | Out-Null

# Copiar archivos del Origen en el directorio de Respaldo
Write-Host "Backing Up..."
Write-Host ""
$errores = @()
foreach ($ruta in $rutas_Origen) {
  try {
    Copy-Item -Path $ruta -Destination $ruta_Respaldo -Recurse -Force -ErrorAction Stop
  }
  catch {
    $errores += $_ # $($_.TargetObject) Para saber qué objeto se intentó copiar
    if ($_.TargetObject) {
      Write-Error "Fail: $($_.TargetObject)"
    } else { Write-Error "Fail: $ruta" }
  }
}

if ($errores.Count -gt 0) {
  Write-Host "Incomplete Backup: $ruta_Respaldo"
  Write-Host ""
  Write-Host "Found Errors:"
  Write-Host "---------------------------------"
  foreach ($e in $errores) {
    Write-Host "File: $($e.TargetObject)"
    Write-Host "Details: $($e.Exception.Message)"
    Write-Host ""
  }
  exit 1

} else {
  Write-Host "Backup completed in: $ruta_Respaldo"
}


Write-Host ""

Write-Host "Size comparison (Original vs Backup)"

# Verificar que existen los directorios de origen y respaldo
foreach ($ruta in $rutas_Origen) {
  if (-not (Test-Path $ruta)) {
    Write-Warning "The route $ruta doesn't exist"
    return
  }
}

if (-not (Test-Path $ruta_Respaldo)) {
  Write-Warning "The backup is inside $ruta_Respaldo"
  return
}

######### La estructura de la salida de Disk Usage debe ser:
# PS C:\WINDOWS\system32>
# >> $size = & du -q $(Get-Location)\TESTS-Respaldar-PortableHDD\RespaldoHDD
# >> $size | Out-Host
# Processing...
#
#
# DU v1.62 - Directory disk usage reporter
# Copyright (C) 2005-2018 Mark Russinovich
# Sysinternals - www.sysinternals.com
#
# Files:        2
# Directories:  4
# Size:         1,108 bytes
# Size on disk: 28,672 bytes


function Get-DUBytes {
  param(
    [string]$DU_exe_param,
    [string]$ruta_param
  )
  
  $line = & $DU_exe_param -q $ruta_param 2>$null | Select-String "Size:\s"
  if ($line) {
    return ($line.Line -replace '[^\d]', '') -as [int64]
  }
  return 0
}

$sizeA = 0
$iter = 0
forEach ($ruta in $rutas_Origen) {
  $iter ++
  Write-Host "Measuring Folder: $iter"
  $sizeA += Get-DUBytes -DU_exe_param $DU_exe -ruta_param $ruta
}

if (-not (Test-Path $ruta_Respaldo)) {
  Write-Warning "The Backup isn't in $ruta_Respaldo"
  return
}

####################### Test (Tamaño lógico acumulativo) ##################
# $rutas_Origen = @(
#     "$(Get-Location)\TESTS-Respaldar-PortableHDD\RespaldoHDD",
#     "$(Get-Location)\TESTS-Respaldar-PortableHDD\Test2"
# )
#
# $size = 0
# forEach ($ruta in $rutas_Origen) {
#     $line = du -q $ruta 2>$null | Select-String "Size:\s"
#     if ($line) {
#         $size += $line.Line -replace '[^\d]', '' -as [int64]
#     }
# }
#
# Write-Host "Total Size: $size bytes"

$sizeB = (
  & $DU_exe -q $ruta_Respaldo |
  Select-String "Size:" |
  Select-Object -First 1 |
  ForEach-Object {
    ($_ -replace '[^\d]', '') -as [int64]
  }
)

Write-Host "Size Origin: $sizeA"
Write-Host "Size Backup: $sizeB"

Write-Host ""

# Cantidad de archivos del directorio de respaldo
Write-Host "Counting files inside the Backup..."
Write-Host ""
$files_respaldo = 0
if (Test-Path $ruta_Respaldo) {
  $enumerator = [System.IO.Directory]::EnumerateFiles($ruta_Respaldo, "*", [System.IO.SearchOption]::AllDirectories)

  forEach ($file in $enumerator) {
    $files_respaldo++
  }
}

Write-Host "Amount of Files"
Write-Host "Original: $files_original"
Write-Host "Backup: $files_respaldo"

$diferencia = [Math]::Abs($files_original - $files_respaldo)
Write-Host "Difference: $diferencia files"