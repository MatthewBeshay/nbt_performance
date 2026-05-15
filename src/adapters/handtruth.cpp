// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Matthew Beshay

#include "bench_common.hpp"

#include "nbt.hpp"

#include <cstddef>
#include <exception>
#include <istream>
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

void BM_handtruth_operator_in(benchmark::State &state)
{
        const auto &bytes = nbt_perf::bench::bigtest();
        for (auto _ : state) {
                try {
                        span_streambuf sb{reinterpret_cast<const char *>(bytes.data()), bytes.size()};
                        std::istream is{&sb};
                        nbt::contexts::java.set(is);
                        nbt::tags::compound_tag root;
                        nbt::operator>>(is, root);
                        benchmark::DoNotOptimize(root);
                } catch (const std::exception &) {
                        // ignore
                }
        }
        nbt_perf::bench::set_bigtest_throughput(state);
}
BENCHMARK(BM_handtruth_operator_in);

} // namespace
