<#
  Este script crea grupos de usuarios en PowerShell. 
  Cabeceras CSV
  NombreGrupo;Descripcion

EJ CSV
NombreGrupo;Descripcion
Almacén;Departamento de almacenes
#>
# Definir el parámetro del script
param (
    [string]$csvPath  # Recibe la ruta del archivo CSV como argumento
)

# Verificar si se proporcionó la ruta del archivo CSV
if (-not $csvPath) {
    Write-Host "Uso: .\grupos.ps1 C:\ruta\grupos.csv" -ForegroundColor Cyan
    exit
}

# Verificar si el archivo existe
if (-Not (Test-Path $csvPath)) {
    Write-Host "El archivo no existe. Verifica la ruta e intenta nuevamente." -ForegroundColor Red
    exit
}

# Definir la Unidad Organizativa (OU) donde se crearán los grupos
$ou = "CN=Builtin,DC=Medicalia,DC=local"

# Importar los grupos desde el CSV
$grupos = Import-Csv -Path $csvPath -Delimiter ";"

# Verificar si el archivo tiene las columnas correctas
if ($grupos -and -not ($grupos[0].PSObject.Properties.Name -contains "NombreGrupo")) {
    Write-Host "Error: El CSV debe contener las columnas 'NombreGrupo' y 'Descripcion'." -ForegroundColor Red
    exit
}

# Iterar sobre la lista de grupos y crearlos en Active Directory
foreach ($grupo in $grupos) {
    $nombre = $grupo.NombreGrupo
    $descripcion = $grupo.Descripcion

    # Validar que las variables no estén vacías
    if (-not $nombre -or -not $descripcion) {
        Write-Host "Error: Una línea del CSV está incompleta. Verifica los datos." -ForegroundColor Red
        continue
    }

    # Verificar si el grupo ya existe en Active Directory
    $existe = Get-ADGroup -Filter "Name -eq '$nombre'" -ErrorAction SilentlyContinue

    if (-not $existe) {
        # Crear el grupo si no existe
        New-ADGroup -Name $nombre -SamAccountName $nombre -GroupCategory Security -GroupScope Global -Path $ou -Description $descripcion
        Write-Host "Grupo '$nombre' creado correctamente con la descripción: $descripcion" -ForegroundColor Green
    } else {
        Write-Host "El grupo '$nombre' ya existe." -ForegroundColor Yellow
    }
}
