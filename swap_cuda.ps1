$baseCudaPath = "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA"

if (Test-Path $baseCudaPath) {
    Write-Host "🔍 Looking for installed cuda versions..." -ForegroundColor Cyan
    
    $versions = Get-ChildItem -Path $baseCudaPath -Directory | Where-Object { $_.Name -match '^v\d+\.\d+' }
    
    if ($versions.Count -gt 0) {
        Write-Host "Versions found :" -ForegroundColor Green
        foreach ($v in $versions) {
            $cleanVersion = $v.Name.Substring(1)
            Write-Host "  • $cleanVersion"
        }
    } else {
        Write-Warning "No CUDA version found at $baseCudaPath"
    }
} else {
    Write-Warning "Base CUDA directory ($baseCudaPath) does not exist."
}
Write-Host ""
# ---------------------------------------------------

$targetVersion = Read-Host "Enter the desired CUDA version (e.g., 11.3)"
$envPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$cudaPath = "$baseCudaPath\v$targetVersion"
$binPath = "$cudaPath\bin"
$libnvvpPath = "$cudaPath\libnvvp"

if (-Not (Test-Path $cudaPath)) {
    Write-Host "ERROR: CUDA version $targetVersion is not installed at expected location: $cudaPath" -ForegroundColor Red
    exit
}

# Update CUDA_PATH
[System.Environment]::SetEnvironmentVariable("CUDA_PATH", $cudaPath, "Machine")
Write-Host "✅ Updated CUDA_PATH to $cudaPath" -ForegroundColor Green

# Update system Path

# Remove target version's bin/libnvvp if they exist to avoid duplication
$filteredPaths = $envPath.Split(";") | Where-Object {
    ($_ -ne $binPath) -and ($_ -ne $libnvvpPath)
}

# Insert target paths at the front
$newPaths = @($binPath, $libnvvpPath)
$updatedPath = ($newPaths + $filteredPaths) -join ";"

# Save updated path
[System.Environment]::SetEnvironmentVariable("Path", $updatedPath, "Machine")

Write-Host "✅ Updated system Path to prioritize CUDA $targetVersion" -ForegroundColor Green
Write-Host ""
Write-Host "Please restart your terminal and run 'nvcc --version' to verify the change." -ForegroundColor Yellow
