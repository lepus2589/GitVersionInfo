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

TEST_CASE("Expect git_version_info_add_compile_definitions() to rebuild with the new SHA1 hash, if the Git dirty state changed: ")

find_package(Git REQUIRED)

execute_process(
    COMMAND
    "${CMAKE_COMMAND}"
    --workflow
    --preset mock-default
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/header-test-mock-project"
    RESULT_VARIABLE BUILD_STATUS_CODE_SECOND_RUN
    OUTPUT_VARIABLE BUILD_LOG
)

execute_process(
    COMMAND "${GIT_EXECUTABLE}" rev-parse HEAD
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/header-test-mock-project"
    OUTPUT_VARIABLE GIT_HEAD_SHA1_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if (BUILD_LOG MATCHES "TEST_VERSION_HASH_01=${GIT_HEAD_SHA1_HASH}")
    set(TARGET_01_WAS_REBUILT_SECOND_RUN YES)
else ()
    set(TARGET_01_WAS_REBUILT_SECOND_RUN NO)
endif ()

if (BUILD_LOG MATCHES "TEST_VERSION_HASH_02=${GIT_HEAD_SHA1_HASH}")
    set(TARGET_02_WAS_REBUILT_SECOND_RUN YES)
else ()
    set(TARGET_02_WAS_REBUILT_SECOND_RUN NO)
endif ()

REQUIRE_STREQUAL(BUILD_STATUS_CODE_SECOND_RUN "0")
REQUIRE_TRUTHY(TARGET_01_WAS_REBUILT_SECOND_RUN)
REQUIRE_TRUTHY(TARGET_02_WAS_REBUILT_SECOND_RUN)
