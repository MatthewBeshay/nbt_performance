# JaanDev/nbtpp adapter - small C++23 NBT lib.
# https://github.com/JaanDev/nbtpp

include(FetchContent)

set(NBTPP_ZLIB     OFF CACHE BOOL "" FORCE)
set(NBTPP_EXAMPLES OFF CACHE BOOL "" FORCE)

FetchContent_Declare(jaandev_nbtpp
    GIT_REPOSITORY https://github.com/JaanDev/nbtpp.git
    GIT_TAG        main
    GIT_SHALLOW    TRUE
)
FetchContent_MakeAvailable(jaandev_nbtpp)

# Upstream uses std::endian without including <bit>.
if(MSVC)
    target_compile_options(nbtpp PRIVATE /w /FIbit)
else()
    target_compile_options(nbtpp PRIVATE -w -include bit)
endif()

add_library(nbt_perf_jaandev OBJECT
    "${CMAKE_CURRENT_SOURCE_DIR}/src/adapters/jaandev.cpp"
)
target_include_directories(nbt_perf_jaandev PRIVATE
    "${jaandev_nbtpp_SOURCE_DIR}/src"
)
target_link_libraries(nbt_perf_jaandev PRIVATE nbt_perf_adapter_iface)
if(MSVC)
    target_compile_options(nbt_perf_jaandev PRIVATE /w /EHsc)
endif()

list(APPEND NBT_PERF_ADAPTER_OBJECTS $<TARGET_OBJECTS:nbt_perf_jaandev>)
list(APPEND NBT_PERF_ADAPTER_NAMES   jaandev)
list(APPEND NBT_PERF_EXTRA_LIBS      nbtpp)
