// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Matthew Beshay

#include "bench_common.hpp"

#include <nbt/io/NBTIO.hpp>
#include <nbt/types/NbtFileFormat.hpp>

#include <exception>
#include <string_view>

namespace {

void BM_glacie_parseFromContent(benchmark::State &state)
{
        const auto &bytes = nbt_perf::bench::bigtest();
        for (auto _ : state) {
                try {
                        std::string_view content{
                                reinterpret_cast<const char *>(bytes.data()),
                                bytes.size(),
                        };
                        auto result = nbt::io::parseFromContent(
                                content,
                                nbt::NbtFileFormat::BigEndian,
                                /*strictMatchSize=*/false);
                        benchmark::DoNotOptimize(result);
                } catch (const std::exception &) {
                        // ignore
                }
        }
        nbt_perf::bench::set_bigtest_throughput(state);
}
BENCHMARK(BM_glacie_parseFromContent);

} // namespace
