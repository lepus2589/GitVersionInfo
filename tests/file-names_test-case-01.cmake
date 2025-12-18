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

TEST_CASE("Expect _git_version_info_file_names() to not set the _GIT_VERSION_INFO_STATE_FILE and _GIT_VERSION_INFO_HEAD_SHA1_FILE variables, if not in a Git repository: ")

set(ENV{GIT_DIR} "not-a-git-repository")

_git_version_info_set_up()
_git_version_info_check()
_git_version_info_toplevel_hash()

_git_version_info_file_names()

REQUIRE_UNDEFINED(_GIT_VERSION_INFO_STATE_FILE)
REQUIRE_UNDEFINED(_GIT_VERSION_INFO_HEAD_SHA1_FILE)
