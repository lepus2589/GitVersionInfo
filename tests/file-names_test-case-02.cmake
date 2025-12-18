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

TEST_CASE("Expect _git_version_info_file_names() to set the _GIT_VERSION_INFO_STATE_FILE and _GIT_VERSION_INFO_HEAD_SHA1_FILE variables and create the respective files, if in a Git repository: ")

_git_version_info_set_up()
_git_version_info_check()
_git_version_info_toplevel_hash()

_git_version_info_file_names()

execute_process(
    COMMAND "${GIT_EXECUTABLE}" rev-parse --show-toplevel
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    OUTPUT_VARIABLE _GIT_TOPLEVEL
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
cmake_path(HASH _GIT_TOPLEVEL _GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_CHECK)

if (NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/_git_version_info_state_${_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_CHECK}.txt")
    message(SEND_ERROR "File '${CMAKE_CURRENT_BINARY_DIR}/_git_version_info_state_${_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_CHECK}.txt' does not exist!")
endif ()

REQUIRE_STREQUAL(_GIT_VERSION_INFO_STATE_FILE "${CMAKE_CURRENT_BINARY_DIR}/_git_version_info_state_${_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_CHECK}.txt")

if (NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/_git_version_info_head_sha1_${_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_CHECK}.txt")
    message(SEND_ERROR "File '${CMAKE_CURRENT_BINARY_DIR}/_git_version_info_head_sha1_${_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_CHECK}.txt' does not exist!")
endif ()

REQUIRE_STREQUAL(_GIT_VERSION_INFO_HEAD_SHA1_FILE "${CMAKE_CURRENT_BINARY_DIR}/_git_version_info_head_sha1_${_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_CHECK}.txt")
