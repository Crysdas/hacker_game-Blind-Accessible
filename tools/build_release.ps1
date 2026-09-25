# build_release.ps1 - hardened release build of Hacker Simulator: Zero Day
# Packs all sound assets into an AES-encrypted game.dat (pack_file), embeds it
# into the executable via '#pragma embed', and ships the engine libraries
# (audio backend + NVDA screen-reader bridge) next to the exe.
# Result: a single folder with an exe whose sounds are encrypted inside it -
# no loose audio files are extractable.
# Requires NVGT 0.90.0-dev or newer (C:\NVGT by default).
param(
    [string]$Root = "C:\StreamPlayer\hacker_game",
    [string]$Nvgt = "C:\NVGT\nvgt.exe",
    [string]$Key  = "0day-nvgt-2026-key",
    [string]$OutName = "HackerSimulatorZeroDay"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

# --- 1. Build encrypted game.dat. pack_file resolves paths relative to the
#        SCRIPT's directory, so the builder script must live in the game root ---
$builder = Join-Path $Root "_build_pack.nvgt"
$scr = New-Object System.Collections.Generic.List[string]
$scr.Add("void main() {")
$scr.Add("    pack_file p;")
$scr.Add("    if (!p.create(""game.dat"", ""$Key"")) { return; }")
$count = 0
foreach ($f in (Get-ChildItem (Join-Path $Root "sounds") -Recurse -File)) {
    $rel = $f.FullName.Substring($Root.Length + 1).Replace("\", "/")
    $scr.Add("    p.add_file(""$rel"", ""$rel"");")
    $count++
}
$scr.Add("    if (p.close()) { }")
$scr.Add("}")
[System.IO.File]::WriteAllLines($builder, $scr.ToArray(), (New-Object System.Text.UTF8Encoding($false)))

Push-Location $Root
try {
    & $Nvgt $builder | Out-Null
} finally {
    Pop-Location
}
Remove-Item $builder -Force -ErrorAction SilentlyContinue

$dat = Join-Path $Root "game.dat"
if (-not (Test-Path $dat)) { throw "game.dat was not created" }
$datBytes = [System.IO.File]::ReadAllBytes($dat)
$datText = [System.Text.Encoding]::ASCII.GetString($datBytes)
if ($datText.Contains("OggS") -or $datText.Contains("RIFF")) { throw "WARNING-fail: game.dat contains raw audio magic (encryption not applied)!" }
Write-Output ("OK: game.dat encrypted, " + $count + " files, " + [math]::Round($datBytes.Length/1MB,2) + " MB")

# --- 2. Assemble dist sources ---
$dist = Join-Path $Root "dist"
if (Test-Path $dist) { Remove-Item $dist -Recurse -Force }
New-Item -ItemType Directory -Path $dist | Out-Null
Get-ChildItem $Root -Filter "*.nvgt" -File | Where-Object { $_.Name -notlike "_*" } | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $dist $_.Name)
}
Copy-Item $dat (Join-Path $dist "game.dat")
Copy-Item (Join-Path $Root "README.md") (Join-Path $dist "README.md") -ErrorAction SilentlyContinue

# Replace loose-sound bundling with embedded pack
$distMain = Join-Path $dist "main.nvgt"
$content = Get-Content $distMain -Raw
$content = $content -replace '#pragma asset "sounds"', '#pragma embed "game.dat"'
[System.IO.File]::WriteAllText($distMain, $content, (New-Object System.Text.UTF8Encoding($true)))

# --- 3. Compile and extract product (exe + engine libraries) ---
Push-Location $dist
try {
    & $Nvgt --compile main.nvgt --set=build.windows_bundle=2
} finally {
    Pop-Location
}
if ($LASTEXITCODE -ne 0) { throw "compile failed with exit code $LASTEXITCODE" }

$zip = Join-Path $dist "main.zip"
$prod = Join-Path $dist "product"
New-Item -ItemType Directory -Path $prod | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $prod)

$exe = Join-Path $prod "main.exe"
if (-not (Test-Path $exe)) { throw "main.exe not found in product" }
$final = Join-Path $dist ($OutName + ".exe")
Move-Item $exe $final -Force

$libDir = Join-Path $prod "lib"
if (Test-Path $libDir) {
    Get-ChildItem $libDir -File | ForEach-Object { Move-Item $_.FullName (Join-Path $dist $_.Name) -Force }
}

# --- 4. Cleanup: no source/loose assets/zip in dist ---
Remove-Item $prod -Recurse -Force
Remove-Item $zip -Force
Remove-Item (Join-Path $dist "game.dat") -Force -ErrorAction SilentlyContinue
Get-ChildItem $dist -Filter "*.nvgt" -File | Remove-Item -Force

$exeBytes = [System.IO.File]::ReadAllBytes($final)
$exeText = [System.Text.Encoding]::ASCII.GetString($exeBytes)
Write-Output ("OK: " + $OutName + ".exe " + [math]::Round($exeBytes.Length/1MB,2) + " MB")
Write-Output ("exe raw OggS present: " + $exeText.Contains("OggS") + " (if this is from the encrypted pack payload, check game.dat integrity)")
Write-Output ("shipped:")
Get-ChildItem $dist -File | ForEach-Object { Write-Output ("  " + $_.Name) }