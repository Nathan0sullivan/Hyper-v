# set-vhd-resize.ps1

Resize a Hyper-V **VHD/VHDX** file and then extend the boot partition inside the mounted virtual disk so the guest OS can use the newly added space.

This script is intended for Windows environments with the **Hyper-V PowerShell module** available, and it must be run in an **elevated PowerShell session**.

## What the script does

The script performs these actions:

1. Validates that the target VHD/VHDX file exists.
2. Converts the requested size from **GB** to **bytes**.
3. Resizes the virtual disk file with `Resize-VHD`.
4. Mounts the VHD/VHDX with `Mount-VHD`.
5. Finds the mounted disk number.
6. Locates the boot partition on that disk.
7. Expands the boot partition to the maximum supported size.
8. Dismounts the VHD/VHDX.

## Parameters

| Parameter | Type | Required | Description |
|---|---|---:|---|
| `VhdPath` | `string` | Yes | Full path to the `.vhd` or `.vhdx` file. |
| `NewVhdSizeGB` | `UInt64` | Yes | New total size of the virtual disk in gigabytes. |

## Requirements

- Windows host with **Hyper-V** tools installed.
- PowerShell session started **as Administrator**.
- Permissions to access and modify the target VHD/VHDX file.
- Enough physical storage available on the host to support the larger disk size.
- The VHD/VHDX must be eligible for expansion.

## Usage

```powershell
.\set-vhd-resize.ps1 -VhdPath "D:\VMs\Server01\Server01.vhdx" -NewVhdSizeGB 120
```

## Example output

```text
Resizing VHD to 120 GB...
Mounting VHD...
Dismounting VHD...
Boot partition resized successfully.
```

## Important notes

- The new size is the **final total disk size**, not the amount to add.
- The script is designed to resize the **boot partition** after the VHD/VHDX itself is enlarged.
- If the disk layout is unusual, encrypted, or does not expose the expected boot partition, the resize may fail.
- The script catches errors and prints them to the console, but review results carefully after execution.
- Back up important virtual disks before resizing.

## Recommended pre-checks

Before running the script, confirm:

- The VM is shut down, or the disk is otherwise safe to modify.
- You have a current backup or checkpoint strategy appropriate for your environment.
- The requested target size is larger than the current disk size.
- The guest OS and partition layout support online/offline expansion as needed.

## Troubleshooting

### "VHD file not found"

Verify the path passed to `-VhdPath` is correct and accessible from the host.

### Hyper-V cmdlets not recognized

Install or enable the Hyper-V management tools and run the script on a system where `Resize-VHD`, `Mount-VHD`, and `Dismount-VHD` are available.

### Partition resize fails

Possible causes include:

- No boot partition was found on the mounted disk.
- The partition cannot be expanded because of disk layout constraints.
- The VHD was resized, but the partition inside it could not be extended.

Check the mounted disk and partition layout manually with:

```powershell
Get-Disk
Get-Partition
Get-PartitionSupportedSize -DiskNumber <diskNumber> -PartitionNumber <partitionNumber>
```

## Safety recommendation

Test the script against a non-production copy of the VHD/VHDX before using it in production.
