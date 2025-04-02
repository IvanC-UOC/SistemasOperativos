<#
 Creación de las Unidades Orgnizativas en Powershell
 Parametro necesario el csv de las unidades. 
Cabeceras para los csv:
    uo_raiz;uo;ougrupo

CSV
uo_raiz;uo;ougrupo
;Parque
;Parque;Users
;Parque;Equipos
Parque;Users;Almacen
Parque;Users;RRHH
Parque;Users;Nutricion
Parque;Users;Finanzas
Parque;Users;Operaciones
Parque;Users;Directiva
Parque;Equipos;Almacen
Parque;Equipos;RRHH
Parque;Equipos;Nutricion
Parque;Equipos;Finanzas
Parque;Equipos;Operaciones
Parque;Equipos;Directiva
#>
param (
    [string]$csvPath
)

if (-not $csvPath) {
    Write-Host "Uso: .\crear_ous.ps1 C:\ruta\ous.csv" -ForegroundColor Cyan
    exit
}

if (-not (Test-Path $csvPath)) {
    Write-Host "El archivo no existe. Verifica la ruta." -ForegroundColor Red
    exit
}

$ous = Import-Csv -Path $csvPath -Delimiter ";"
$dominio = "DC=medicalia,DC=local"

foreach ($ou in $ous) {
    $nivel1 = $ou.uo_raiz
    $nivel2 = $ou.uo
    $nivel3 = $ou.ougrupo

    # Nivel 1
    if ($nivel1) {
        $dn1 = "OU=$nivel1,$dominio"
        try {
            Get-ADOrganizationalUnit -Identity $dn1 -ErrorAction Stop | Out-Null
            Write-Host "OU '$nivel1' ya existe en '$dominio'" -ForegroundColor Yellow
        } catch {
            New-ADOrganizationalUnit -Name $nivel1 -Path $dominio -ProtectedFromAccidentalDeletion $false
            Write-Host "OU '$nivel1' creada en '$dominio'" -ForegroundColor Green
        }
    }

    # Nivel 2
    if ($nivel2) {
        $path2 = if ($nivel1) { "OU=$nivel1,$dominio" } else { $dominio }
        $dn2 = "OU=$nivel2,$path2"
        try {
            Get-ADOrganizationalUnit -Identity $dn2 -ErrorAction Stop | Out-Null
            Write-Host "OU '$nivel2' ya existe en '$path2'" -ForegroundColor Yellow
        } catch {
            New-ADOrganizationalUnit -Name $nivel2 -Path $path2 -ProtectedFromAccidentalDeletion $false
            Write-Host "OU '$nivel2' creada en '$path2'" -ForegroundColor Green
        }
    }

    # Nivel 3
    if ($nivel3) {
        $path3 = if ($nivel1 -and $nivel2) {
            "OU=$nivel2,OU=$nivel1,$dominio"
        } elseif ($nivel2) {
            "OU=$nivel2,$dominio"
        } else {
            $dominio
        }
        $dn3 = "OU=$nivel3,$path3"
        try {
            Get-ADOrganizationalUnit -Identity $dn3 -ErrorAction Stop | Out-Null
            Write-Host "OU '$nivel3' ya existe en '$path3'" -ForegroundColor Yellow
        } catch {
            New-ADOrganizationalUnit -Name $nivel3 -Path $path3 -ProtectedFromAccidentalDeletion $false
            Write-Host "OU '$nivel3' creada en '$path3'" -ForegroundColor Green
        }
    }
}
