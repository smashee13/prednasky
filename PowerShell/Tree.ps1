param(
    [string]$Path        = (Get-Location),
    [bool]  $FoldersOnly = $true,
    [int]   $Levels      = 1
)

function Get-FolderSize {
    param([string]$folderPath)
    $size = 0
    Get-ChildItem -Path $folderPath -Recurse -File |
      ForEach-Object { $size += $_.Length }
    return $size
}

function Show-Tree {
    param(
        [string] $Path,
        [int]    $Indentation,
        [bool]   $FoldersOnly,
        [int]    $CurrentLevel,
        [int]    $MaxLevel
    )

    # 1) Vypiš soubory na téhle úrovni (jen pokud FoldersOnly = $false a CurrentLevel = 1)
    if (-not $FoldersOnly -and $CurrentLevel -eq 1) {
        Get-ChildItem -Path $Path -File | ForEach-Object {
            $sizeMB = [math]::Round($_.Length / 1MB, 2)
            Write-Host (' ' * $Indentation + "|-- " + $_.Name + "  [$sizeMB MB]")
        }
    }

    # 2) Pro každou podsložku: vypiš ji a pak (pokud CurrentLevel < MaxLevel) zanoř dál
    Get-ChildItem -Path $Path -Directory | ForEach-Object {
        $dirSizeMB = [math]::Round((Get-FolderSize -folderPath $_.FullName) / 1MB, 2)
        Write-Host (' ' * $Indentation + "|-- " + $_.Name + "  [$dirSizeMB MB]")

        if ($CurrentLevel -lt $MaxLevel) {
            Show-Tree `
              -Path $_.FullName `
              -Indentation ($Indentation + 4) `
              -FoldersOnly $FoldersOnly `
              -CurrentLevel ($CurrentLevel + 1) `
              -MaxLevel $MaxLevel
        }
    }
}

Write-Host "Struktura složek pro: $Path"
Show-Tree `
  -Path $Path `
  -Indentation 0 `
  -FoldersOnly $FoldersOnly `
  -CurrentLevel 1 `
  -MaxLevel $Levels
