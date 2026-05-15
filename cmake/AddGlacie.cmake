# GlacieTeam/NBT adapter - C++20 lib (MPL-2.0).
# https://github.com/GlacieTeam/NBT

include(FetchContent)

FetchContent_Declare(glacie_bstream
    GIT_REPOSITORY https://github.com/GlacieTeam/BinaryStream.git
    GIT_TAG        main
    GIT_SHALLOW    TRUE
    SOURCE_SUBDIR  cmake-source-subdir-that-does-not-exist
)
FetchContent_MakeAvailable(glacie_bstream)

FetchContent_Declare(glacie_nbt
    GIT_REPOSITORY https://github.com/GlacieTeam/NBT.git
    GIT_TAG        main
    GIT_SHALLOW    TRUE
    SOURCE_SUBDIR  cmake-source-subdir-that-does-not-exist
)
FetchContent_MakeAvailable(glacie_nbt)

add_library(nbt_perf_glacie_bstream OBJECT
    "${glacie_bstream_SOURCE_DIR}/src/binarystream/BinaryStream.cpp"
    "${glacie_bstream_SOURCE_DIR}/src/binarystream/ReadOnlyBinaryStream.cpp"
)
target_include_directories(nbt_perf_glacie_bstream PUBLIC
    "${glacie_bstream_SOURCE_DIR}/include"
)
if(MSVC)
    target_compile_options(nbt_perf_glacie_bstream PRIVATE /w /EHsc)
else()
    target_compile_options(nbt_perf_glacie_bstream PRIVATE -w)
endif()

file(GLOB_RECURSE _glacie_sources
    "${glacie_nbt_SOURCE_DIR}/src/nbt/*.cpp"
)
# Exclude the C API wrapper - its tests run main() / link against extras.
list(FILTER _glacie_sources EXCLUDE REGEX "nbt-c/")

add_library(nbt_perf_glacie_lib OBJECT ${_glacie_sources})
target_include_directories(nbt_perf_glacie_lib PUBLIC
    "${glacie_nbt_SOURCE_DIR}/include"
    "${glacie_nbt_SOURCE_DIR}/src"
    "${glacie_bstream_SOURCE_DIR}/include"
)
target_link_libraries(nbt_perf_glacie_lib PUBLIC ZLIB::ZLIB)
if(MSVC)
    target_compile_options(nbt_perf_glacie_lib PRIVATE /w /EHsc)
else()
    target_compile_options(nbt_perf_glacie_lib PRIVATE -w)
endif()

add_library(nbt_perf_glacie OBJECT
    "${CMAKE_CURRENT_SOURCE_DIR}/src/adapters/glacie.cpp"
)
target_include_directories(nbt_perf_glacie PRIVATE
    "${glacie_nbt_SOURCE_DIR}/include"
    "${glacie_bstream_SOURCE_DIR}/include"
)
target_link_libraries(nbt_perf_glacie PRIVATE nbt_perf_adapter_iface)
if(MSVC)
    target_compile_options(nbt_perf_glacie PRIVATE /EHsc)
endif()

list(APPEND NBT_PERF_ADAPTER_OBJECTS
    $<TARGET_OBJECTS:nbt_perf_glacie>
    $<TARGET_OBJECTS:nbt_perf_glacie_lib>
    $<TARGET_OBJECTS:nbt_perf_glacie_bstream>
)
list(APPEND NBT_PERF_ADAPTER_NAMES glacie)
