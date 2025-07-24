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

project(GitVersionInfo VERSION 1.0.0 LANGUAGES NONE)

string(COMPARE EQUAL "${CMAKE_PROJECT_NAME}" "${PROJECT_NAME}" IS_TOP_LEVEL)

if (IS_TOP_LEVEL)
    include(CTest)
endif ()

option(GitVersionInfo_INCLUDE_PACKAGING "Include packaging rules for GitVersionInfo" "${IS_TOP_LEVEL}")

add_subdirectory(src)

if (NOT IS_TOP_LEVEL)
    set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)
endif ()

if (IS_TOP_LEVEL AND BUILD_TESTING)
    add_subdirectory(tests)
endif ()

if (GitVersionInfo_INCLUDE_PACKAGING)
    add_subdirectory(packaging)
endif ()
