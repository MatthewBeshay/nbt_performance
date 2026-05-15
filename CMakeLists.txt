cmake_minimum_required(VERSION 4.0)

project(nbt_performance
    VERSION 0.1.0
    DESCRIPTION "Cross-library benchmark suite for C++ NBT implementations."
    HOMEPAGE_URL "https://github.com/matthewbeshay/nbt_performance"
    LANGUAGES C CXX
)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(benchmark CONFIG REQUIRED)
find_package(ZLIB REQUIRED)
find_package(Boost CONFIG REQUIRED COMPONENTS container)

include(FetchContent)

set(TAGFORGE_GIT_REPOSITORY "https://github.com/matthewbeshay/tagforge.git" CACHE STRING "")
set(TAGFORGE_GIT_TAG        "main"                                          CACHE STRING "")

FetchContent_Declare(tagforge
    GIT_REPOSITORY ${TAGFORGE_GIT_REPOSITORY}
    GIT_TAG        ${TAGFORGE_GIT_TAG}
    GIT_SHALLOW    TRUE
)

# Disable tagforge's optional bits so we don't drag in their tests / CLI.
set(TAGFORGE_BUILD_TESTING    OFF CACHE BOOL "" FORCE)
set(TAGFORGE_BUILD_CLI        OFF CACHE BOOL "" FORCE)
set(TAGFORGE_BUILD_BENCHMARKS OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(tagforge)

set(NBT_PERF_ADAPTER_OBJECTS "")
set(NBT_PERF_ADAPTER_NAMES   "")
set(NBT_PERF_EXTRA_LIBS      "")

add_library(nbt_perf_adapter_iface INTERFACE)
target_include_directories(nbt_perf_adapter_iface INTERFACE
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
)
target_link_libraries(nbt_perf_adapter_iface INTERFACE
    benchmark::benchmark
    tagforge::tagforge_headers
)
target_compile_definitions(nbt_perf_adapter_iface INTERFACE
    NBT_PERF_FIXTURE_DIR="${CMAKE_SOURCE_DIR}/fixtures"
)

include(cmake/AddCelisium.cmake      OPTIONAL)
include(cmake/AddMaspitz.cmake       OPTIONAL)
include(cmake/AddPrismLauncher.cmake OPTIONAL)
include(cmake/AddHandtruth.cmake     OPTIONAL)
include(cmake/AddSpockBot.cmake      OPTIONAL)
include(cmake/AddJaanDev.cmake       OPTIONAL)
include(cmake/AddBlacksmith.cmake    OPTIONAL)
include(cmake/AddGlacie.cmake        OPTIONAL)
include(cmake/AddM4xi1m3.cmake       OPTIONAL)

add_executable(nbt_bench src/bench_main.cpp ${NBT_PERF_ADAPTER_OBJECTS})
target_link_libraries(nbt_bench
    PRIVATE
        tagforge::tagforge
        benchmark::benchmark
        benchmark::benchmark_main
        ZLIB::ZLIB
        ${NBT_PERF_EXTRA_LIBS}
)
if(NBT_PERF_BLACKSMITH_LINK_FLAGS)
    target_link_options(nbt_bench PRIVATE ${NBT_PERF_BLACKSMITH_LINK_FLAGS})
endif()
target_include_directories(nbt_bench PRIVATE src)
target_compile_definitions(nbt_bench PRIVATE
    NBT_PERF_FIXTURE_DIR="${CMAKE_SOURCE_DIR}/fixtures"
)

if(MSVC)
    target_compile_options(nbt_bench PRIVATE /W4 /permissive- /Zc:__cplusplus /utf-8 /EHsc)
else()
    target_compile_options(nbt_bench PRIVATE -Wall -Wextra -Wpedantic)
endif()
