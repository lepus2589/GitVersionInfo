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

TEST_CASE("Expect _git_version_info_toplevel_hash() to set the _GIT_TOPLEVEL_HASH variable, if in a Git repository: ")

_git_version_info_check()

_git_version_info_toplevel_hash()

cmake_path(HASH CMAKE_CURRENT_SOURCE_DIR _CURRENT_SOURCE_DIR_HASH_CHECK)

execute_process(
    COMMAND "${GIT_EXECUTABLE}" rev-parse --show-toplevel
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    OUTPUT_VARIABLE _GIT_TOPLEVEL
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
cmake_path(HASH _GIT_TOPLEVEL "_GIT_TOPLEVEL_HASH_CHECK_${_CURRENT_SOURCE_DIR_HASH_CHECK}")

REQUIRE_STREQUAL(_GIT_TOPLEVEL_HASH_${_CURRENT_SOURCE_DIR_HASH_CHECK} ${_GIT_TOPLEVEL_HASH_CHECK_${_CURRENT_SOURCE_DIR_HASH_CHECK}})
