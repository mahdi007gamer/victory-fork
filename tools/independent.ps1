# Build and run independent diagnostics. No title binaries or assets are used.
[CmdletBinding()]
param(
    [ValidateSet('Validate','Analyze','Hardware','Package','Menu')]
    [string]$Action = 'Menu',
    [string]$Samples
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
function Invoke-Checked {
    param([string]$Program, [string[]]$Arguments)
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program exited with code $LASTEXITCODE" }
}
if ($Action -eq 'Menu') {
    Write-Host 'VIctory Independent | Diagnostics'
    Write-Host '1: Validate reference tools'
    Write-Host '2: Analyze frame samples'
    Write-Host '3: Hardware inventory'
    Write-Host '4: Package validated tools'
    switch (Read-Host 'Select') {
        '1' { $Action = 'Validate' }
        '2' { $Action = 'Analyze'; $Samples = Read-Host 'Frame timing text file' }
        '3' { $Action = 'Hardware' }
        '4' { $Action = 'Package' }
        default { return }
    }
}
if ($Action -eq 'Hardware') {
    & (Join-Path $PSScriptRoot 'hardware-report.ps1')
    return
}
if ($Action -eq 'Analyze') {
    if (-not $Samples) { throw 'Specify -Samples with a text file of frame durations in ms' }
    $Samples = (Resolve-Path -LiteralPath $Samples).Path
}
$work = Join-Path ([IO.Path]::GetTempPath()) ('victory-tools-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
Push-Location $root
try {
    $stats = Join-Path $work 'frame_stats.exe'
    $statsSource = Join-Path $PSScriptRoot 'frame_stats.rs'
    Invoke-Checked -Program rustc -Arguments @('--edition=2024','-D','warnings',$statsSource,'-o',$stats)
    if ($Action -eq 'Analyze') {
        Get-Content -LiteralPath $Samples | & $stats
        if ($LASTEXITCODE -ne 0) { throw 'Frame analyzer failed' }
        return
    }
    foreach ($name in @('frame_stats','render_reference')) {
        $test = Join-Path $work ($name + '_test.exe')
        $source = Join-Path $PSScriptRoot ($name + '.rs')
        Invoke-Checked -Program rustc -Arguments @('--edition=2024','--test','-D','warnings',$source,'-o',$test)
        Invoke-Checked -Program $test -Arguments @()
    }
    if ($Action -eq 'Package') {
        $stage = Join-Path $work 'package'
        New-Item -ItemType Directory -Path $stage | Out-Null
        Copy-Item $stats $stage
        $toolStage = Join-Path $stage 'tools'
        New-Item -ItemType Directory -Path $toolStage | Out-Null
        foreach ($name in @('frame_stats.rs','render_reference.rs','hardware-report.ps1','independent.ps1')) {
            Copy-Item (Join-Path $PSScriptRoot $name) $toolStage
        }
        Copy-Item (Join-Path $root 'LICENSE') $stage
        Copy-Item (Join-Path $root 'rust-toolchain.toml') $stage
        Invoke-Checked -Program git -Arguments @('rev-parse','HEAD') | Set-Content (Join-Path $stage 'commit.txt')
        Invoke-Checked -Program rustc -Arguments @('-Vv') | Set-Content (Join-Path $stage 'toolchain.txt')
        Get-ChildItem $stage -File -Recurse | Sort-Object FullName | ForEach-Object {
            (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant() + '  ' + $_.FullName.Substring($stage.Length + 1).Replace('\','/')
        } | Set-Content (Join-Path $stage 'SHA256SUMS.txt')
        $zip = Join-Path ([IO.Path]::GetTempPath()) ('victory-diagnostics-' + [guid]::NewGuid().ToString('N') + '.zip')
        Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip
        Write-Output $zip
    }
} finally {
    Pop-Location
    Remove-Item -LiteralPath $work -Recurse -Force
}
