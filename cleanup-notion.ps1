param([string]$tempDir)

Write-Host "[PS] Cleaning files in: $tempDir"

# Clean files: .html, .csv, .md
Get-ChildItem -Path $tempDir -Recurse -File -Include *.html, *.csv, *.md | ForEach-Object {
    if ($_.BaseName -match '^(.*?)(\s?[a-f0-9\-]{32,36})$') {
        $newName = "$($matches[1])$($_.Extension)"
        Rename-Item $_.FullName -NewName $newName -Force
        Write-Host "Renamed file: $($_.Name) -> $newName"
    }
}

# Clean folders (deepest first)
Get-ChildItem -Path $tempDir -Recurse -Directory | Sort-Object FullName -Descending | ForEach-Object {
    if ($_.Name -match '^(.*?)(\s?[a-f0-9\-]{32,36})$') {
        $newName = $matches[1]
        Rename-Item $_.FullName -NewName $newName -Force
        Write-Host "Renamed folder: $($_.Name) -> $newName"
    }
}
