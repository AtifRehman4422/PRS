# Patch Firebase C++ SDK CMake to fix "Compatibility with CMake < 3.5 has been removed" on Windows.
# Run this if you get that error (e.g. after flutter clean). Then run: flutter build windows

$path = Join-Path $PSScriptRoot "..\build\windows\x64\extracted\firebase_cpp_sdk_windows\CMakeLists.txt"
if (-not (Test-Path $path)) {
  Write-Host "Firebase SDK not extracted yet. Run 'flutter build windows' once; if it fails with CMake 3.5 error, run this script, then 'flutter build windows' again."
  exit 1
}
$content = Get-Content $path -Raw
if ($content -match 'cmake_minimum_required\(VERSION 3\.1\)') {
  $content = $content -replace 'cmake_minimum_required\(VERSION 3\.1\)', 'cmake_minimum_required(VERSION 3.5)'
  Set-Content $path -Value $content -NoNewline
  Write-Host "Patched: $path (3.1 -> 3.5). You can run 'flutter build windows' now."
} else {
  Write-Host "Already patched or format changed: $path"
}
exit 0
