// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Matthew Beshay

#pragma once

#include "tagforge/io.hpp"

#include <benchmark/benchmark.h>

#include <cstddef>
#include <cstdint>
#include <filesystem>
#include <stdexcept>
#include <vector>

namespace nbt_perf::bench {

inline const std::vector<std::byte> &bigtest()
{
        static const auto bytes = [] {
                const auto path = std::filesystem::path{NBT_PERF_FIXTURE_DIR} / "bigtest_raw.nbt";
                auto b = tagforge::read_file(path);
                if (!b) {
                        throw std::runtime_error{"could not load " + path.string()};
                }
                return std::move(*b);
        }();
        return bytes;
}

inline void set_bigtest_throughput(benchmark::State &state)
{
        state.SetBytesProcessed(static_cast<std::int64_t>(state.iterations()) * bigtest().size());
}

} // namespace nbt_perf::bench
