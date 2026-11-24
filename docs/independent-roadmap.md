# Independent development roadmap

## Scope
Maintain an independently developed, GPL-3.0-or-later compatibility research project. Preserve upstream attribution and license notices. Use authorized software and original or redistributable synthetic fixtures; do not distribute proprietary game assets or implement protection bypasses.

## Milestones
- [ ] M1: Reproducible Windows build, locked dependencies, formatting, Clippy and workspace tests.
- [ ] M2: Synthetic benchmark harness with frame-time percentiles, CPU/GPU timing, memory use and machine/build metadata.
- [ ] M3: Graphics correctness tests with original fixtures and reference outputs.
- [ ] M4: Profile and optimize demonstrated bottlenecks; reject regressions in correctness or stability.
- [ ] M5: NVIDIA and AMD hardware validation matrix with reproducible results.
- [ ] M6: Independent launcher for authorized test workloads, configuration validation and diagnostics.
- [ ] M7: Alpha packaging, checksums, release notes and documented limitations.

## Baseline
Upstream fork README reports 2.5–4 FPS in its title-specific workload, 30 FPS in menus, and around 24 GB memory usage on one machine. These are inherited, unverified reports, not independent benchmark results.

## Acceptance rules
Every performance claim must include build SHA, hardware, driver, workload, configuration, sample duration and before/after results. Do not publish a playable or compatibility claim without a reproducible test. Preserve the main branch until changes are reviewed and tests pass.
