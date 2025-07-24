#[[
MIT License

CMake build script for GitVersionInfo module
Copyright (c) 2025 Tim Kaune

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

set(CMAKE_MAXIMUM_SUPPORTED_VERSION 3.31)

cmake_minimum_required(VERSION 3.30...${CMAKE_MAXIMUM_SUPPORTED_VERSION})

project(GitVersionInfoTriggerTest VERSION 1.0.0 LANGUAGES C)

add_executable(trigger_test trigger_test.c)

add_custom_command(
    TARGET trigger_test
    POST_BUILD
    COMMAND trigger_test
)

add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/trigger_test.txt"
    COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/trigger_test.txt"
    COMMAND "${CMAKE_COMMAND}" -E echo "TriggerTestCustom was rebuilt!"
    VERBATIM
)
add_custom_target(
    trigger_test_custom ALL
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/trigger_test.txt"
)

include(../../src/cmake/GitVersionInfo.cmake)

git_version_info_add_dependant_source_files(
    TARGET trigger_test
    SOURCES
    trigger_test.c
)

git_version_info_add_dependant_source_files(
    TARGET trigger_test_custom
    SOURCES
    "${CMAKE_CURRENT_BINARY_DIR}/trigger_test.txt"
)
