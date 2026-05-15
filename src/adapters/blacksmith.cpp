// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Matthew Beshay

#include "bench_common.hpp"

#include <nbt-blacksmith/ios-bin.hpp>
#include <nbt-blacksmith/nbt.hpp>

#include <cstdint>
#include <exception>
#include <istream>
#include <iterator>
#include <memory>
#include <streambuf>

namespace {

class span_streambuf final : public std::streambuf {
public:
        span_streambuf(const char *data, std::size_t size)
        {
                auto *p = const_cast<char *>(data);
                setg(p, p, p + size);
        }
};

void BM_blacksmith_sbin(benchmark::State &state)
{
        const auto &bytes = nbt_perf::bench::bigtest();
        for (auto _ : state) {
                try {
                        span_streambuf sb{reinterpret_cast<const char *>(bytes.data()), bytes.size()};
                        std::istream is{&sb};
                        is.unsetf(std::ios::skipws);
                        std::istream_iterator<std::uint8_t> beg{is}, end;
                        blacksmith::sbin stream(beg, end);
                        std::shared_ptr<blacksmith::Tag> root;
                        stream >> root;
                        benchmark::DoNotOptimize(root);
                } catch (const std::exception &) {
                        // ignore
                }
        }
        nbt_perf::bench::set_bigtest_throughput(state);
}
BENCHMARK(BM_blacksmith_sbin);

} // namespace
