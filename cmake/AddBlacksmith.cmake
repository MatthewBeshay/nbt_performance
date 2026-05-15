# max-ishere/nbt-blacksmith adapter - C++20 lib, streams-based.
# https://github.com/max-ishere/nbt-blacksmith

include(FetchContent)
FetchContent_Declare(blacksmith_nbt
    GIT_REPOSITORY https://github.com/max-ishere/nbt-blacksmith.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE
    SOURCE_SUBDIR  cmake-source-subdir-that-does-not-exist
)
FetchContent_MakeAvailable(blacksmith_nbt)

foreach(_blacksmith_src ios-bin.cpp list.cpp tag.cpp)
    set(_path "${blacksmith_nbt_SOURCE_DIR}/src/${_blacksmith_src}")
    file(READ "${_path}" _contents)
    string(REGEX REPLACE "#warning[^\n]*" "" _contents "${_contents}")
    file(WRITE "${_path}" "${_contents}")
endforeach()

add_library(nbt_perf_blacksmith_lib OBJECT
    "${blacksmith_nbt_SOURCE_DIR}/src/array.cpp"
    "${blacksmith_nbt_SOURCE_DIR}/src/compound.cpp"
    "${blacksmith_nbt_SOURCE_DIR}/src/ios-bin.cpp"
    "${blacksmith_nbt_SOURCE_DIR}/src/list.cpp"
    "${blacksmith_nbt_SOURCE_DIR}/src/primitive.cpp"
    "${blacksmith_nbt_SOURCE_DIR}/src/sbin.cpp"
    "${blacksmith_nbt_SOURCE_DIR}/src/tag.cpp"
)
target_include_directories(nbt_perf_blacksmith_lib PUBLIC "${blacksmith_nbt_SOURCE_DIR}/include")
if(MSVC)
    target_compile_options(nbt_perf_blacksmith_lib PRIVATE /w /EHsc)
else()
    target_compile_options(nbt_perf_blacksmith_lib PRIVATE -w)
endif()

add_library(nbt_perf_blacksmith OBJECT
    "${CMAKE_CURRENT_SOURCE_DIR}/src/adapters/blacksmith.cpp"
)
target_include_directories(nbt_perf_blacksmith PRIVATE
    "${blacksmith_nbt_SOURCE_DIR}/include"
)
target_link_libraries(nbt_perf_blacksmith PRIVATE nbt_perf_adapter_iface)
if(MSVC)
    target_compile_options(nbt_perf_blacksmith PRIVATE /EHsc)
endif()

list(APPEND NBT_PERF_ADAPTER_OBJECTS
    $<TARGET_OBJECTS:nbt_perf_blacksmith>
    $<TARGET_OBJECTS:nbt_perf_blacksmith_lib>
)
list(APPEND NBT_PERF_ADAPTER_NAMES blacksmith)

set(NBT_PERF_BLACKSMITH_LINK_FLAGS "" CACHE INTERNAL "")
if(MSVC)
    set(NBT_PERF_BLACKSMITH_LINK_FLAGS "/FORCE:MULTIPLE" CACHE INTERNAL "")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    set(NBT_PERF_BLACKSMITH_LINK_FLAGS "-Wl,--allow-multiple-definition" CACHE INTERNAL "")
endif()
