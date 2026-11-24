# Local inventory only; no network requests or automatic upload.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$cpu = @(Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors)
$gpu = @(Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, DriverDate)
$os = Get-CimInstance Win32_OperatingSystem
$machine = Get-CimInstance Win32_ComputerSystem
[ordered]@{
    schema_version = 1
    captured_utc = [DateTime]::UtcNow.ToString('o')
    os = $os.Caption
    os_build = $os.BuildNumber
    physical_ram_bytes = [uint64]$machine.TotalPhysicalMemory
    cpu = $cpu
    gpu = $gpu
} | ConvertTo-Json -Depth 5
