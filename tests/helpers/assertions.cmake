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

macro(TEST_CASE DESCRIPTION)
    message(NOTICE "${DESCRIPTION}")
endmacro()

macro(REQUIRE_FALSY VAR_NAME)
    if (NOT DEFINED ${VAR_NAME})
        message(FATAL_ERROR "${VAR_NAME} is NOT DEFINED!")
    elseif (${VAR_NAME})
        message(FATAL_ERROR "${VAR_NAME} is TRUTHY!")
    else ()
        message(STATUS "${VAR_NAME} is DEFINED and FALSY.")
    endif ()
endmacro()

macro(CHECK_FALSY VAR_NAME)
    if (NOT DEFINED ${VAR_NAME})
        message(SEND_ERROR "${VAR_NAME} is NOT DEFINED!")
    elseif (${VAR_NAME})
        message(SEND_ERROR "${VAR_NAME} is TRUTHY!")
    else ()
        message(STATUS "${VAR_NAME} is DEFINED and FALSY.")
    endif ()
endmacro()

macro(REQUIRE_TRUTHY VAR_NAME)
    if (NOT DEFINED ${VAR_NAME})
        message(FATAL_ERROR "${VAR_NAME} is NOT DEFINED!")
    elseif (NOT ${VAR_NAME})
        message(FATAL_ERROR "${VAR_NAME} is FALSY!")
    else ()
        message(STATUS "${VAR_NAME} is DEFINED and TRUTHY.")
    endif ()
endmacro()

macro(CHECK_TRUTHY VAR_NAME)
    if (NOT DEFINED ${VAR_NAME})
        message(SEND_ERROR "${VAR_NAME} is NOT DEFINED!")
    elseif (NOT ${VAR_NAME})
        message(SEND_ERROR "${VAR_NAME} is FALSY!")
    else ()
        message(STATUS "${VAR_NAME} is DEFINED and TRUTHY.")
    endif ()
endmacro()

macro(REQUIRE_UNDEFINED VAR_NAME)
    if (DEFINED ${VAR_NAME})
        message(FATAL_ERROR "${VAR_NAME} is DEFINED!")
    else ()
        message(STATUS "${VAR_NAME} is NOT DEFINED.")
    endif ()
endmacro()

macro(CHECK_UNDEFINED VAR_NAME)
    if (DEFINED ${VAR_NAME})
        message(SEND_ERROR "${VAR_NAME} is DEFINED!")
    else ()
        message(STATUS "${VAR_NAME} is NOT DEFINED.")
    endif ()
endmacro()

macro(REQUIRE_DEFINED VAR_NAME)
    if (NOT DEFINED ${VAR_NAME})
        message(FATAL_ERROR "${VAR_NAME} is NOT DEFINED!")
    else ()
        message(STATUS "${VAR_NAME} is DEFINED.")
    endif ()
endmacro()

macro(CHECK_DEFINED VAR_NAME)
    if (NOT DEFINED ${VAR_NAME})
        message(SEND_ERROR "${VAR_NAME} is NOT DEFINED!")
    else ()
        message(STATUS "${VAR_NAME} is DEFINED.")
    endif ()
endmacro()

macro(SET_TARGET_MOCK TARGET_NAME)
    set(ENV{${TARGET_NAME}} TRUE)
endmacro()

macro(REQUIRE_TARGET_UNDEFINED TARGET_NAME)
    if (DEFINED ENV{${TARGET_NAME}})
        message(FATAL_ERROR "${TARGET_NAME} is DEFINED!")
    else ()
        message(STATUS "${TARGET_NAME} is NOT DEFINED.")
    endif ()
endmacro()

macro(CHECK_TARGET_UNDEFINED TARGET_NAME)
    if (DEFINED ENV{${TARGET_NAME}})
        message(SEND_ERROR "${TARGET_NAME} is DEFINED!")
    else ()
        message(STATUS "${TARGET_NAME} is NOT DEFINED.")
    endif ()
endmacro()

macro(REQUIRE_TARGET_DEFINED TARGET_NAME)
    if (NOT DEFINED ENV{${TARGET_NAME}})
        message(FATAL_ERROR "${TARGET_NAME} is NOT DEFINED!")
    else ()
        message(STATUS "${TARGET_NAME} is DEFINED.")
    endif ()
endmacro()

macro(CHECK_TARGET_DEFINED TARGET_NAME)
    if (NOT DEFINED ENV{${TARGET_NAME}})
        message(SEND_ERROR "${TARGET_NAME} is NOT DEFINED!")
    else ()
        message(STATUS "${TARGET_NAME} is DEFINED.")
    endif ()
endmacro()

macro(REQUIRE_STREQUAL VAR_NAME VALUE)
    if (NOT ${VAR_NAME} STREQUAL "${VALUE}")
        message(FATAL_ERROR "${VAR_NAME} with value `${${VAR_NAME}}` is NOT STREQUAL to `${VALUE}`!")
    else ()
        message(STATUS "${VAR_NAME} is STREQUAL to `${VALUE}`.")
    endif ()
endmacro()

macro(CHECK_STREQUAL VAR_NAME VALUE)
    if (NOT ${VAR_NAME} STREQUAL "${VALUE}")
        message(SEND_ERROR "${VAR_NAME} with value `${${VAR_NAME}}` is NOT STREQUAL to `${VALUE}`!")
    else ()
        message(STATUS "${VAR_NAME} is STREQUAL to `${VALUE}`.")
    endif ()
endmacro()
