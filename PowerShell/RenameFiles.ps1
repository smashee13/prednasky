param(
    [string]$Path,
    [string]$Prefix = "soubor",
    [switch]$ByDate
)

Add-Type -AssemblyName System.Windows.Forms

# Pokud není zadán Path, zobraz dialogové okno pro výběr složky
if (-not $Path) {
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Vyber složku se soubory k přejmenování"
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $Path = $folderBrowser.SelectedPath
    } else {
        Write-Host "Nebyla vybrána žádná složka. Skript bude ukončen."
        exit
    }
}

# Kontrola existence složky
if (!(Test-Path $Path)) {
    Write-Error "Zadaná cesta '$Path' neexistuje."
    exit
}

# Výpis info
Write-Host "Pracuji ve složce: $Path"
Write-Host "Prefix: $Prefix"
Write-Host "Řazení: $($ByDate.IsPresent ? 'podle data vytvoření' : 'podle jména')"

# Získání a seřazení souborů
$files = Get-ChildItem -Path $Path -File
$files = if ($ByDate) {
    $files | Sort-Object CreationTime
} else {
    $files | Sort-Object Name
}

# Přejmenování
$i = 0
foreach ($file in $files) {
    $ext = $file.Extension
    $newName = "{0}{1}{2}" -f $Prefix, ($i.ToString("000")), $ext
    $newPath = Join-Path -Path $file.DirectoryName -ChildPath $newName

    Rename-Item -Path $file.FullName -NewName $newPath
    $i++
}

Write-Host "Hotovo. Přejmenováno $i soubor(ů)."
