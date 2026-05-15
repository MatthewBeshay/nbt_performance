# nbt_performance

Performance profiling of C++ NBT (Minecraft Named Binary Tag) implementations, driven by [Google Benchmark](https://github.com/google/benchmark). Every benchmarked library is pulled via `FetchContent` - nothing is vendored. Workload: decode `bigtest_raw.nbt` (1544 bytes, Java named-root NBT).

## Quickstart

```pwsh
cmake --preset msvc
cmake --build --preset msvc-release
.\build\msvc\Release\nbt_bench.exe
```

## Latest results (15 May, 2026)

MSVC 19.51 (VS 2026 Insiders), x64 Release, single thread (Ryzen 9 5950x), [Google Benchmark](https://github.com/google/benchmark) with `--benchmark_min_time=2s`.

Sorted fastest to slowest decoder (run with `--benchmark_min_time=2s`):

| Library                                                                          |    Throughput |
|----------------------------------------------------------------------------------|--------------:|
| **[tagforge](https://github.com/matthewbeshay/tagforge)** *(skip, no alloc.)*    |    6.30 GiB/s |
| **[tagforge](https://github.com/matthewbeshay/tagforge)** *(decode, owning)*     |     392 MiB/s |
| [GlacieTeam/NBT](https://github.com/GlacieTeam/NBT)                              |     328 MiB/s |
| [Celisium/libnbt](https://github.com/Celisium/libnbt)                            |     326 MiB/s |
| [JaanDev/nbtpp](https://github.com/JaanDev/nbtpp)                                |     255 MiB/s |
| [maspitz/nbtview](https://github.com/maspitz/nbtview)                            |     220 MiB/s |
| [PrismLauncher/libnbtplusplus](https://github.com/PrismLauncher/libnbtplusplus)  |     206 MiB/s |
| [SpockBotMC/cpp-nbt](https://github.com/SpockBotMC/cpp-nbt)                      |      62 MiB/s |
| [handtruth/nbt-cpp](https://github.com/handtruth/nbt-cpp)                        |      45 MiB/s |
| [max-ishere/nbt-blacksmith](https://github.com/max-ishere/nbt-blacksmith)        |      39 MiB/s |
| [M4xi1m3/nbtpp](https://github.com/M4xi1m3/nbtpp)                                |      38 MiB/s |

tagforge wins every head-to-head ~20% over the next contender ([GlacieTeam/NBT](https://github.com/GlacieTeam/NBT)), ~30% over [Celisium/libnbt](https://github.com/Celisium/libnbt), ~7× over the slowest C++ contestants. Allocation-free `skip` sets the absolute ceiling at 6.30 GiB/s about 16× the owning-tree throughput, which is what a "give me an NBT tree I can mutate" workload pays for the heap structure.

## Methodology

- Same input bytes for every contestant (`bigtest_raw.nbt`, preloaded into a function-local static; no I/O cost in the hot loop).
- `state.SetBytesProcessed(iterations * input.size())` so Google Benchmark reports throughput per byte processed.
- Single thread, MSVC Release / x64, default optimisation flags.
- Output shape varies (owning tree, zero-copy view, malloc'd C tree, throwing variant) this measures time-to-decode.

## CI

GitHub Actions verify the bench compiles and runs with smoke parameters
on every push. The README numbers are author-curated after a run on a
stable machine; CI runners are too noisy for reproducible perf
comparisons.

## License

MIT see [LICENSE](LICENSE). Adapter code is MIT; each pulled
competitor retains its own license, applied to that competitor's source
only. The bench harness never bundles competitor source it links via
`FetchContent`.
