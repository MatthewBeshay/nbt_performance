# M4xi1m3/nbtpp adapter - C++11 lib, depends on M4xi1m3/std-extended.
# https://github.com/M4xi1m3/nbtpp

include(FetchContent)

FetchContent_Declare(m4xi1m3_stde
    GIT_REPOSITORY https://github.com/M4xi1m3/std-extended.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE
    SOURCE_SUBDIR  cmake-source-subdir-that-does-not-exist
)
FetchContent_MakeAvailable(m4xi1m3_stde)

FetchContent_Declare(m4xi1m3_nbtpp
    GIT_REPOSITORY https://github.com/M4xi1m3/nbtpp.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE
    SOURCE_SUBDIR  cmake-source-subdir-that-does-not-exist
)
FetchContent_MakeAvailable(m4xi1m3_nbtpp)

# Minimal stde subset: streams (data + endian), and gzip stub since
# nbt.cpp pulls the header. The gzip TU itself isn't called in our
# bench (we feed raw bytes), but the linker needs the symbols.
add_library(nbt_perf_m4xi1m3_stde OBJECT
    "${m4xi1m3_stde_SOURCE_DIR}/src/streams/data_istream.cpp"
    "${m4xi1m3_stde_SOURCE_DIR}/src/streams/data_ostream.cpp"
    "${m4xi1m3_stde_SOURCE_DIR}/src/streams/endian.cpp"
    "${m4xi1m3_stde_SOURCE_DIR}/src/streams/gzip.cpp"
)
target_include_directories(nbt_perf_m4xi1m3_stde PUBLIC
    "${m4xi1m3_stde_SOURCE_DIR}/include"
    # Upstream src/ files use unqualified `streams/data.hpp` includes that
    # only resolve when include/stde/ is on the path.
    "${m4xi1m3_stde_SOURCE_DIR}/include/stde"
)
target_link_libraries(nbt_perf_m4xi1m3_stde PUBLIC ZLIB::ZLIB)
if(MSVC)
    target_compile_options(nbt_perf_m4xi1m3_stde PRIVATE /w /EHsc)
else()
    # Upstream stde/streams/data.hpp uses uint8_t etc. without including
    # <cstdint>. GCC 13 rejects this; MSVC pulls it in transitively.
    target_compile_options(nbt_perf_m4xi1m3_stde PRIVATE -w "SHELL:-include cstdint")
endif()

add_library(nbt_perf_m4xi1m3_lib OBJECT
    "${m4xi1m3_nbtpp_SOURCE_DIR}/src/nbt.cpp"
    "${m4xi1m3_nbtpp_SOURCE_DIR}/src/tag.cpp"
)
target_include_directories(nbt_perf_m4xi1m3_lib PUBLIC
    "${m4xi1m3_nbtpp_SOURCE_DIR}/include"
    "${m4xi1m3_nbtpp_SOURCE_DIR}/include/nbtpp"
    "${m4xi1m3_stde_SOURCE_DIR}/include"
)
if(MSVC)
    target_compile_options(nbt_perf_m4xi1m3_lib PRIVATE /w /EHsc)
else()
    target_compile_options(nbt_perf_m4xi1m3_lib PRIVATE -w)
endif()

add_library(nbt_perf_m4xi1m3 OBJECT
    "${CMAKE_CURRENT_SOURCE_DIR}/src/adapters/m4xi1m3.cpp"
)
target_include_directories(nbt_perf_m4xi1m3 PRIVATE
    "${m4xi1m3_nbtpp_SOURCE_DIR}/include"
    "${m4xi1m3_stde_SOURCE_DIR}/include"
)
target_link_libraries(nbt_perf_m4xi1m3 PRIVATE nbt_perf_adapter_iface)
if(MSVC)
    target_compile_options(nbt_perf_m4xi1m3 PRIVATE /EHsc)
endif()

list(APPEND NBT_PERF_ADAPTER_OBJECTS
    $<TARGET_OBJECTS:nbt_perf_m4xi1m3>
    $<TARGET_OBJECTS:nbt_perf_m4xi1m3_lib>
    $<TARGET_OBJECTS:nbt_perf_m4xi1m3_stde>
)
list(APPEND NBT_PERF_ADAPTER_NAMES m4xi1m3)
