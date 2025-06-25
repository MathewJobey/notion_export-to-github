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
Write-Host "`n[PS] Fixing internal HTML references..."

# Step 1: Build old-to-new name map
$replacementMap = @{}
Get-ChildItem -Path $tempDir -Recurse -File | ForEach-Object {
    if ($_.Name -match '^(.*?)(\s?[a-f0-9\-]{32,36})(\.\w+)$') {
        $original = $_.Name
        $cleaned = "$($matches[1])$($matches[3])"
        $replacementMap[$original] = $cleaned
    }
}

# Step 2: Update all HTML files
Get-ChildItem -Path $tempDir -Recurse -Filter *.html | ForEach-Object {
    $filePath = $_.FullName
    $html = Get-Content $filePath -Raw

    foreach ($oldName in $replacementMap.Keys) {
        $newName = $replacementMap[$oldName]
        # Escape regex chars in file names
        $escapedOld = [Regex]::Escape($oldName)
        $html = $html -replace $escapedOld, $newName
    }

    Set-Content $filePath $html -Encoding UTF8
    Write-Host "[OK] Fixed internal links in: $($_.Name)"
}

