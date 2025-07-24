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

TEST_CASE("Expect git_version_info_add_dependants() to trigger a rebuild, if the Git dirty state changed: ")

execute_process(
    COMMAND
    "${CMAKE_COMMAND}"
    --workflow
    --preset mock-default
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/trigger-test-mock-project"
    RESULT_VARIABLE BUILD_STATUS_CODE_SECOND_RUN
    OUTPUT_VARIABLE BUILD_LOG
)

if (BUILD_LOG MATCHES [=[TriggerTest was rebuilt!]=])
    set(REGULAR_SOURCE_WAS_REBUILT_SECOND_RUN YES)
else ()
    set(REGULAR_SOURCE_WAS_REBUILT_SECOND_RUN NO)
endif ()

if (BUILD_LOG MATCHES [=[TriggerTestCustom was rebuilt!]=])
    set(GENERATED_SOURCE_WAS_REBUILT_SECOND_RUN YES)
else ()
    set(GENERATED_SOURCE_WAS_REBUILT_SECOND_RUN NO)
endif ()

REQUIRE_STREQUAL(BUILD_STATUS_CODE_SECOND_RUN "0")
REQUIRE_TRUTHY(REGULAR_SOURCE_WAS_REBUILT_SECOND_RUN)
REQUIRE_TRUTHY(GENERATED_SOURCE_WAS_REBUILT_SECOND_RUN)
