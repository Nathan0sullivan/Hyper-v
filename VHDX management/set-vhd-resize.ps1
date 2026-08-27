# Resize a boot partition inside a VHD/VHDX
# Run as Administrator

param (
    [Parameter(Mandatory = $true)]
    [string]$VhdPath,          # Full path to the VHD/VHDX file
    [Parameter(Mandatory = $true)]
    [UInt64]$NewVhdSizeGB      # New total VHD size in GB
)

try {
    # Validate file exists
    if (-not (Test-Path $VhdPath)) {
        throw "VHD file not found: $VhdPath"
    }

    # Convert GB to bytes
    $NewVhdSizeBytes = $NewVhdSizeGB * 1GB

    Write-Host "Resizing VHD to $NewVhdSizeGB GB..." -ForegroundColor Cyan
    Resize-VHD -Path $VhdPath -SizeBytes $NewVhdSizeBytes

    Write-Host "Mounting VHD..." -ForegroundColor Cyan
    $disk = Mount-VHD -Path $VhdPath -PassThru

    # Get the disk number
    $diskNumber = $disk.DiskNumber

    # Get the boot/system partition (usually the largest or with OS)
    $partition = Get-Partition -DiskNumber $diskNumber |
                 Where-Object { $_.Type -eq 'Basic' -and $_.GptType -ne $null } |
                 Sort-Object Size -Descending |
                 Select-Object -First 1

    if (-not $partition) {
        throw "Boot partition not found."
    }

    Write-Host "Resizing partition number $($partition.PartitionNumber) on disk $diskNumber..." -ForegroundColor Cyan
    Resize-Partition -DiskNumber $diskNumber -PartitionNumber $partition.PartitionNumber -Size ($disk | Get-Disk | Get-PartitionSupportedSize | Select-Object -ExpandProperty SizeMax)

    Write-Host "Dismounting VHD..." -ForegroundColor Cyan
    Dismount-VHD -Path $VhdPath

    Write-Host "Boot partition resized successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}