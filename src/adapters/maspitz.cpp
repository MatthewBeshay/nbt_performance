// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Matthew Beshay

#include "bench_common.hpp"

#include "nbtview.hpp"

#include <exception>

namespace {

void BM_maspitz_read_binary(benchmark::State &state)
{
        const auto &bytes = nbt_perf::bench::bigtest();
        for (auto _ : state) {
                try {
                        auto result = nbtview::read_binary(
                                reinterpret_cast<const unsigned char *>(bytes.data()),
                                bytes.size());
                        benchmark::DoNotOptimize(result);
                } catch (const std::exception &) {
                        // ignore - bench just measures the attempt
                }
        }
        nbt_perf::bench::set_bigtest_throughput(state);
}
BENCHMARK(BM_maspitz_read_binary);

} // namespace
