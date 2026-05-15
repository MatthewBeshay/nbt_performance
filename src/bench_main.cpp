// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Matthew Beshay

#include "bench_common.hpp"

#include "tagforge/decode.hpp"
#include "tagforge/format.hpp"
#include "tagforge/skip.hpp"

static void BM_tagforge_skip(benchmark::State &state)
{
        const auto &bytes = nbt_perf::bench::bigtest();
        for (auto _ : state) {
                auto r = tagforge::skip(bytes, tagforge::Format::JavaNamedRoot);
                benchmark::DoNotOptimize(r);
        }
        nbt_perf::bench::set_bigtest_throughput(state);
}
BENCHMARK(BM_tagforge_skip);

static void BM_tagforge_decode(benchmark::State &state)
{
        const auto &bytes = nbt_perf::bench::bigtest();
        for (auto _ : state) {
                auto r = tagforge::decode(bytes, tagforge::Format::JavaNamedRoot);
                benchmark::DoNotOptimize(r);
        }
        nbt_perf::bench::set_bigtest_throughput(state);
}
BENCHMARK(BM_tagforge_decode);
