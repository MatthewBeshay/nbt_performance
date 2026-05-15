# handtruth-nbt-cpp adapter - C++17 lib, meson upstream.
# https://github.com/handtruth/nbt-cpp

include(FetchContent)
FetchContent_Declare(handtruth_nbt_cpp
    GIT_REPOSITORY https://github.com/handtruth/nbt-cpp.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE
    SOURCE_SUBDIR  cmake-source-subdir-that-does-not-exist
)
FetchContent_MakeAvailable(handtruth_nbt_cpp)

add_library(nbt_perf_handtruth_lib OBJECT
    "${handtruth_nbt_cpp_SOURCE_DIR}/src/nbt.cpp"
    # Skip nbtc.cpp - it defines main() (the upstream CLI tool).
)
target_include_directories(nbt_perf_handtruth_lib PUBLIC "${handtruth_nbt_cpp_SOURCE_DIR}/include")
if(MSVC)
    target_compile_options(nbt_perf_handtruth_lib PRIVATE /w /EHsc /FIcstdint)
else()
    target_compile_options(nbt_perf_handtruth_lib PRIVATE -w -include cstdint)
endif()

add_library(nbt_perf_handtruth OBJECT
    "${CMAKE_CURRENT_SOURCE_DIR}/src/adapters/handtruth.cpp"
)
target_include_directories(nbt_perf_handtruth PRIVATE
    "${handtruth_nbt_cpp_SOURCE_DIR}/include"
)
target_link_libraries(nbt_perf_handtruth PRIVATE nbt_perf_adapter_iface)

list(APPEND NBT_PERF_ADAPTER_OBJECTS
    $<TARGET_OBJECTS:nbt_perf_handtruth>
    $<TARGET_OBJECTS:nbt_perf_handtruth_lib>
)
list(APPEND NBT_PERF_ADAPTER_NAMES handtruth)
