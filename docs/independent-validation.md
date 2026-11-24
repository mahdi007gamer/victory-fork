# Independent validation guide

Run from a Windows checkout with the pinned Rust toolchain and PowerShell.

```powershell
git switch development/independent
./tools/independent.ps1 -Action Validate
./tools/independent.ps1 -Action Hardware
./tools/independent.ps1 -Action Analyze -Samples C:\Temp\frames.txt
./tools/independent.ps1 -Action Package
```

The analyzer accepts one positive finite duration in milliseconds per line.
Its FPS is 1000 divided by the arithmetic mean frame duration. Percentiles
use nearest rank. Report the sample count, workload, build commit, GPU driver,
settings and duration separately. Do not compare dissimilar workloads.

The reference tests are original CPU fixtures for depth and premultiplied alpha,
not a test of the actual GPU renderer. Hardware inventory is local-only and
excludes account, machine and serial identifiers. No data is uploaded.
The package is a ZIP of independent diagnostic tools and source, not a game or
a playable release. Packaging requires a Git checkout.

## Milestone gates

| Phase | Implemented | Evidence still required |
| --- | --- | --- |
| 01 Build | Windows CI, tests, release build and CLI smoke test | Successful Actions run |
| 02 Analysis | Frame timing summary and tests | Actual CPU/GPU timing, memory and repeatable workload integration |
| 03 Rendering | Original CPU reference tests | GPU comparisons against reference outputs |
| 04 Optimization | Benchmark measurement foundation | Profiles, identified bottlenecks, verified improvements |
| 05 Hardware | Local Windows inventory script | Real NVIDIA and AMD validation |
| 06 Launcher | Interactive diagnostic menu | Desktop GUI and independent workload configuration |
| 07 Alpha | Diagnostic ZIP packaging and CI artifacts | Passing builds, review and validated release |

Do not label the project complete or playable while these gates remain open.
