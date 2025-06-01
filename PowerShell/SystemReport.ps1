param(
    [string]$OutFile
)

function Write-OutputSmart {
    param (
        [string]$Text
    )
    Write-Host $Text
    if ($OutFile) {
        $Text | Out-File -FilePath $OutFile -Append -Encoding UTF8
    }
}

function Write-Section {
    param(
        [string]$Title
    )
    Write-OutputSmart "`n=== $Title ==="
}

# Vyčistit starý výstup
if ($OutFile) {
    Remove-Item -Path $OutFile -ErrorAction SilentlyContinue
}

# OBECNÉ INFORMACE
Write-Section "OBECNÉ INFORMACE"
$data = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model, Name, SystemType, @{Name="TotalPhysicalMemory(GB)";Expression={[math]::Round($_.TotalPhysicalMemory / 1GB, 2)}}
Write-OutputSmart ($data | Out-String)

# OPERAČNÍ SYSTÉM
Write-Section "OPERAČNÍ SYSTÉM"
$data = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture, RegisteredUser, SerialNumber, InstallDate
Write-OutputSmart ($data | Out-String)

# PROCESOR
Write-Section "PROCESOR"
$data = Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
Write-OutputSmart ($data | Out-String)

# PAMĚŤ RAM
Write-Section "PAMĚŤ RAM"
$data = Get-CimInstance Win32_PhysicalMemory | ForEach-Object {
    [PSCustomObject]@{
        KapacitaGB   = "{0:N2}" -f ($_.Capacity / 1GB)
        RychlostMHz  = $_.Speed
        Výrobce      = $_.Manufacturer
        Slot         = $_.BankLabel
    }
}
Write-OutputSmart ($data | Out-String)

# GRAFICKÁ KARTA
Write-Section "GRAFICKÁ KARTA"
$data = Get-CimInstance Win32_VideoController | ForEach-Object {
    $pamet = if ($_.AdapterRAM -and $_.AdapterRAM -gt 0) {
        "$([math]::Round($_.AdapterRAM / 1MB)) MB"
    } else {
        "Neznámá"
    }

    [PSCustomObject]@{
        Název         = $_.Name
        Paměť         = $pamet
        Ovladač       = $_.DriverVersion
        VideoProcesor = $_.VideoProcessor
    }
}
Write-OutputSmart ($data | Out-String)

# DISKY
Write-Section "DISKY"
$data = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
Select-Object DeviceID, VolumeName, FileSystem, 
@{Name="VelikostGB";Expression={[math]::Round($_.Size / 1GB)}},
@{Name="VolnoGB";Expression={[math]::Round($_.FreeSpace / 1GB)}}
Write-OutputSmart ($data | Out-String)

# SÍŤOVÉ ADAPTÉRY
Write-Section "SÍŤOVÉ ADAPTÉRY"
$data = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } |
Select-Object Description, MACAddress, IPAddress, DefaultIPGateway
Write-OutputSmart ($data | Out-String)

# LICENCE WINDOWS
Write-Section "LICENCE WINDOWS"
$lic = (cscript.exe //Nologo "$env:SystemRoot\System32\slmgr.vbs" /dli) 2>&1
Write-OutputSmart $lic

# ČAS
Write-Section "GENEROVÁNO"
Write-OutputSmart (Get-Date)

# Výpis o uložení
if ($OutFile) {
    Write-Host "`nZpráva byla uložena do: $OutFile" -ForegroundColor Green
}
