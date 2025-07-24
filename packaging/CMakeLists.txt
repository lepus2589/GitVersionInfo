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

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

if (NOT DEFINED GitVersionInfo_INSTALL_CMAKEDIR)
    set(
        GitVersionInfo_INSTALL_CMAKEDIR
        "${CMAKE_INSTALL_DATAROOTDIR}/cmake/${PROJECT_NAME}-${PROJECT_VERSION}"
    )
endif ()

install(
    FILES
    "../LICENSE"
    RENAME copyright
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME}-${PROJECT_VERSION}"
)

write_basic_package_version_file(
    GitVersionInfoConfigVersion.cmake
    COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
    "GitVersionInfoConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/GitVersionInfoConfig.cmake"
    INSTALL_DESTINATION "${GitVersionInfo_INSTALL_CMAKEDIR}"
    PATH_VARS GitVersionInfo_INSTALL_CMAKEDIR
)

install(
    FILES
    "${CMAKE_CURRENT_BINARY_DIR}/GitVersionInfoConfigVersion.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/GitVersionInfoConfig.cmake"
    "../src/cmake/GitVersionInfo.cmake"
    DESTINATION "${GitVersionInfo_INSTALL_CMAKEDIR}"
)
