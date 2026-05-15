// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Matthew Beshay

#include "bench_common.hpp"

extern "C" {
#include "nbt.h"
}

#include <cstdint>
#include <cstring>

namespace {

struct buffer_reader {
        const std::uint8_t *data;
        std::size_t size;
        std::size_t pos;
};

extern "C" std::size_t celisium_buffer_read_cb(void *userdata, std::uint8_t *out, std::size_t n)
{
        auto *r = static_cast<buffer_reader *>(userdata);
        const std::size_t left = r->size - r->pos;
        const std::size_t copy = (n < left) ? n : left;
        std::memcpy(out, r->data + r->pos, copy);
        r->pos += copy;
        return copy;
}

void BM_celisium_nbt_parse(benchmark::State &state)
{
        const auto &bytes = nbt_perf::bench::bigtest();
        for (auto _ : state) {
                buffer_reader r{
                        .data = reinterpret_cast<const std::uint8_t *>(bytes.data()),
                        .size = bytes.size(),
                        .pos = 0,
                };
                nbt_reader_t reader{
                        .read = celisium_buffer_read_cb,
                        .userdata = &r,
                };
                nbt_tag_t *tag = nbt_parse(reader, NBT_PARSE_FLAG_USE_RAW);
                benchmark::DoNotOptimize(tag);
                if (tag) nbt_free_tag(tag);
        }
        nbt_perf::bench::set_bigtest_throughput(state);
}
BENCHMARK(BM_celisium_nbt_parse);

} // namespace
