// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Matthew Beshay

#include "bench_common.hpp"

#include "nbtpp.hpp"

#include <cstdint>
#include <cstring>
#include <exception>
#include <stdexcept>
#include <vector>

namespace {

// Take a Java named-root NBT buffer and return a copy with the root
// compound's name removed. Equivalent payload, JaanDev-compatible
// (its loadFromBytes assumes the root name is empty).
std::vector<std::byte> jaandev_strip_root_name(std::span<const std::byte> bytes)
{
        if (bytes.size() < 3) {
                throw std::runtime_error{"input too small to strip root name"};
        }
        const auto name_hi = static_cast<std::uint8_t>(bytes[1]);
        const auto name_lo = static_cast<std::uint8_t>(bytes[2]);
        const std::size_t name_len = (static_cast<std::size_t>(name_hi) << 8) | name_lo;
        const std::size_t prefix = 3 + name_len;
        if (bytes.size() < prefix) {
                throw std::runtime_error{"input shorter than declared root name"};
        }
        std::vector<std::byte> out;
        out.reserve(bytes.size() - name_len);
        out.push_back(bytes[0]);          // root tag
        out.push_back(std::byte{0});      // name_len high
        out.push_back(std::byte{0});      // name_len low
        out.insert(out.end(), bytes.begin() + prefix, bytes.end());
        return out;
}

const std::vector<std::byte> &jaandev_input()
{
        static const auto stripped = jaandev_strip_root_name(nbt_perf::bench::bigtest());
        return stripped;
}

void BM_jaandev_loadFromBytes(benchmark::State &state)
{
        const auto &bytes = jaandev_input();
        for (auto _ : state) {
                try {
                        std::span<std::uint8_t> mut{
                                const_cast<std::uint8_t *>(reinterpret_cast<const std::uint8_t *>(bytes.data())),
                                bytes.size(),
                        };
                        auto compound = nbt::loadFromBytes(mut);
                        benchmark::DoNotOptimize(compound);
                } catch (const std::exception &) {
                        // ignore
                }
        }
        // Throughput reported relative to the *original* bigtest size for
        // apples-to-apples comparison against the other contestants.
        nbt_perf::bench::set_bigtest_throughput(state);
}
BENCHMARK(BM_jaandev_loadFromBytes);

} // namespace
