# SpockBotMC/cpp-nbt adapter - single-header C++20 lib (zlib license).
# https://github.com/SpockBotMC/cpp-nbt

include(FetchContent)
FetchContent_Declare(spockbot_nbt
    GIT_REPOSITORY https://github.com/SpockBotMC/cpp-nbt.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE
    SOURCE_SUBDIR  cmake-source-subdir-that-does-not-exist
)
FetchContent_MakeAvailable(spockbot_nbt)

add_library(nbt_perf_spockbot OBJECT
    "${CMAKE_CURRENT_SOURCE_DIR}/src/adapters/spockbot.cpp"
)
target_include_directories(nbt_perf_spockbot PRIVATE "${spockbot_nbt_SOURCE_DIR}")
target_link_libraries(nbt_perf_spockbot PRIVATE
    nbt_perf_adapter_iface
    Boost::container
)
if(MSVC)
    target_compile_options(nbt_perf_spockbot PRIVATE /w /EHsc)
endif()

list(APPEND NBT_PERF_ADAPTER_OBJECTS $<TARGET_OBJECTS:nbt_perf_spockbot>)
list(APPEND NBT_PERF_ADAPTER_NAMES   spockbot)
