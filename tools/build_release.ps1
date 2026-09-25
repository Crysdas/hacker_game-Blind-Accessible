# build_release.ps1 - hardened release build of Hacker Simulator: Zero Day
# Produces a single standalone EXE with all sounds embedded as resources and
# release-compiled (obfuscated) script bytecode. No loose audio or zip with
# extractable files.
# Requires NVGT 0.90.0-dev or newer (C:\NVGT by default).
param(
    [string]$Root = "C:\StreamPlayer\hacker_game",
    [string]$Nvgt = "C:\NVGT\nvgt.exe",
    [string]$OutName = "HackerSimulatorZeroDay"
)

$ErrorActionPreference = "Stop"

$dist = Join-Path $Root "dist"
if (Test-Path $dist) { Remove-Item $dist -Recurse -Force }
New-Item -ItemType Directory -Path $dist | Out-Null

# Distribute from a clean copy of the project sources
Get-ChildItem $Root -Filter "*.nvgt" -File | Where-Object { $_.Name -notlike "_*" } | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $dist $_.Name)
}
Copy-Item (Join-Path $Root "README.md") (Join-Path $dist "README.md") -ErrorAction SilentlyContinue
Copy-Item (Join-Path $Root "sounds") (Join-Path $dist "sounds") -Recurse -ErrorAction Stop

Push-Location $dist
try {
    & $Nvgt --compile main.nvgt --set=build.windows_bundle=0
} finally {
    Pop-Location
}
if ($LASTEXITCODE -ne 0) { throw "compile failed with exit code $LASTEXITCODE" }

$exe = Join-Path $dist "main.exe"
if (-not (Test-Path $exe)) { throw "main.exe was not produced" }
$final = Join-Path $dist ($OutName + ".exe")
Move-Item $exe $final -Force

# Remove loose sounds from the dist so nothing extractable ships alongside the exe
Remove-Item (Join-Path $dist "sounds") -Recurse -Force
# Sources were only needed for the compiler; the runnable product is the exe
Get-ChildItem $dist -Filter "*.nvgt" -File | Remove-Item -Force

$bin = [System.IO.File]::ReadAllBytes($final)
$str = [System.Text.Encoding]::ASCII.GetString($bin)
Write-Output ("OK: " + $OutName + ".exe " + [math]::Round($bin.Length/1MB,2) + " MB")
Write-Output ("sounds embedded: OggS=" + $str.Contains("OggS") + " RIFF=" + $str.Contains("RIFF"))
Write-Output ("loose files in dist:")
Get-ChildItem $dist -Recurse -File | ForEach-Object { Write-Output ("  " + $_.Name) }