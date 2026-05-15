# Celisium-libnbt adapter - single-header C library (CC0).
# https://github.com/Celisium/libnbt

include(FetchContent)
FetchContent_Declare(celisium_libnbt
    GIT_REPOSITORY https://github.com/Celisium/libnbt.git
    GIT_TAG        main
    GIT_SHALLOW    TRUE
    SOURCE_SUBDIR  cmake-source-subdir-that-does-not-exist
)
FetchContent_MakeAvailable(celisium_libnbt)

add_library(nbt_perf_celisium_c OBJECT
    "${CMAKE_CURRENT_SOURCE_DIR}/src/adapters/celisium_impl.c"
    "${celisium_libnbt_SOURCE_DIR}/miniz.c"
)
target_include_directories(nbt_perf_celisium_c PUBLIC "${celisium_libnbt_SOURCE_DIR}")
if(MSVC)
    target_compile_options(nbt_perf_celisium_c PRIVATE /w)
else()
    target_compile_options(nbt_perf_celisium_c PRIVATE -w)
endif()

# C++ wrapper + self-registered Google Benchmark.
add_library(nbt_perf_celisium OBJECT
    "${CMAKE_CURRENT_SOURCE_DIR}/src/adapters/celisium.cpp"
)
target_include_directories(nbt_perf_celisium PRIVATE
    "${celisium_libnbt_SOURCE_DIR}"
)
target_link_libraries(nbt_perf_celisium PRIVATE nbt_perf_adapter_iface)

list(APPEND NBT_PERF_ADAPTER_OBJECTS
    $<TARGET_OBJECTS:nbt_perf_celisium>
    $<TARGET_OBJECTS:nbt_perf_celisium_c>
)
list(APPEND NBT_PERF_ADAPTER_NAMES celisium)
