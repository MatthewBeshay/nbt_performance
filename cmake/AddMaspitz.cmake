# maspitz-nbtview adapter - header-and-impl C++17 lib (Boost license).
# https://github.com/maspitz/nbtview

include(FetchContent)
FetchContent_Declare(maspitz_nbtview
    GIT_REPOSITORY https://github.com/maspitz/nbtview.git
    GIT_TAG        main
    GIT_SHALLOW    TRUE
    SOURCE_SUBDIR  cmake-source-subdir-that-does-not-exist
)
FetchContent_MakeAvailable(maspitz_nbtview)

set(_maspitz_root "${maspitz_nbtview_SOURCE_DIR}/nbtview")

add_library(nbt_perf_maspitz_lib OBJECT
    "${_maspitz_root}/nbtview.cpp"
    "${_maspitz_root}/BinaryDeserializer.cpp"
    "${_maspitz_root}/Region.cpp"
    "${_maspitz_root}/zlib_utils.cpp"
)
target_include_directories(nbt_perf_maspitz_lib PUBLIC "${_maspitz_root}")
target_link_libraries(nbt_perf_maspitz_lib PUBLIC ZLIB::ZLIB)
if(MSVC)
    target_compile_options(nbt_perf_maspitz_lib PRIVATE
        /w /EHsc /FIbit /FIostream /FIstring /FIstdexcept
    )
else()
    target_compile_options(nbt_perf_maspitz_lib PRIVATE
        -w
        "SHELL:-include bit"
        "SHELL:-include ostream"
        "SHELL:-include string"
        "SHELL:-include stdexcept"
    )
endif()

add_library(nbt_perf_maspitz OBJECT
    "${CMAKE_CURRENT_SOURCE_DIR}/src/adapters/maspitz.cpp"
)
target_include_directories(nbt_perf_maspitz PRIVATE "${_maspitz_root}")
target_link_libraries(nbt_perf_maspitz PRIVATE nbt_perf_adapter_iface)
if(MSVC)
    target_compile_options(nbt_perf_maspitz PRIVATE /FIbit /FIostream /FIstring /FIstdexcept)
else()
    target_compile_options(nbt_perf_maspitz PRIVATE
        "SHELL:-include bit"
        "SHELL:-include ostream"
        "SHELL:-include string"
        "SHELL:-include stdexcept"
    )
endif()

list(APPEND NBT_PERF_ADAPTER_OBJECTS
    $<TARGET_OBJECTS:nbt_perf_maspitz>
    $<TARGET_OBJECTS:nbt_perf_maspitz_lib>
)
list(APPEND NBT_PERF_ADAPTER_NAMES maspitz)
