# PrismLauncher-libnbtplusplus adapter - established C++ NBT library (LGPL-3.0).
# https://github.com/PrismLauncher/libnbtplusplus

include(FetchContent)

set(NBT_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(NBT_USE_ZLIB    OFF CACHE BOOL "" FORCE)
set(NBT_NAME        nbtplusplus CACHE STRING "" FORCE)

FetchContent_Declare(prism_libnbtpp
    GIT_REPOSITORY https://github.com/PrismLauncher/libnbtplusplus.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE
)
FetchContent_MakeAvailable(prism_libnbtpp)

add_library(nbt_perf_prism OBJECT
    "${CMAKE_CURRENT_SOURCE_DIR}/src/adapters/prism.cpp"
)
target_include_directories(nbt_perf_prism PRIVATE
    "${prism_libnbtpp_SOURCE_DIR}/include"
    "${prism_libnbtpp_BINARY_DIR}"   # generated nbt_export.h lives here
)
target_link_libraries(nbt_perf_prism PRIVATE nbt_perf_adapter_iface)
if(MSVC)
    target_compile_options(nbt_perf_prism PRIVATE /w /EHsc)
endif()

list(APPEND NBT_PERF_ADAPTER_OBJECTS $<TARGET_OBJECTS:nbt_perf_prism>)
list(APPEND NBT_PERF_ADAPTER_NAMES   prism)
list(APPEND NBT_PERF_EXTRA_LIBS      nbtplusplus)
