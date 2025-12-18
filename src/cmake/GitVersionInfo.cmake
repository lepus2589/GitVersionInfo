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

#[[
This internal macro looks for the Git executable and prepares the necessary
variables for the GitVersionInfo macros.

@param [_GIT_VERSION_INFO_GIT_DIR]: The requested directory to check.
@return
    - GIT_EXECUTABLE: Path to the Git executable
    - _GIT_VERSION_INFO_GIT_DIR: The requested directory to check or CMAKE_CURRENT_SOURCE_DIR.
    - _GIT_VERSION_INFO_GIT_DIR_HASH: The FNV-1a 64bit hash of the requested directory.

Usage:

_git_version_info_set_up()
]]
macro(_git_version_info_set_up)
    if (NOT GIT_EXECUTABLE)
        message(CHECK_START "Looking for git command")
        find_package(Git REQUIRED)
        message(CHECK_PASS "found")
    endif ()

    if (NOT DEFINED _GIT_VERSION_INFO_GIT_DIR OR _GIT_VERSION_INFO_GIT_DIR STREQUAL "")
        set(_GIT_VERSION_INFO_GIT_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    endif ()

    if (NOT DEFINED _GIT_VERSION_INFO_GIT_DIR_HASH)
        cmake_path(HASH _GIT_VERSION_INFO_GIT_DIR _GIT_VERSION_INFO_GIT_DIR_HASH)
    endif ()
endmacro()

#[[
This internal macro checks, if the requested directory is tracked in a Git
repository.

@param _GIT_VERSION_INFO_GIT_DIR: The requested directory to check.
@param _GIT_VERSION_INFO_GIT_DIR_HASH: The FNV-1a 64bit hash of the requested directory.
@return _GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}:
    Truthy, if the requested directory is tracked in a Git repository, falsy
    otherwise.

Usage:

_git_version_info_check()
]]
macro(_git_version_info_check)

block (SCOPE_FOR VARIABLES)

if (NOT DEFINED "_GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}")
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" rev-parse --is-inside-work-tree
        WORKING_DIRECTORY "${_GIT_VERSION_INFO_GIT_DIR}"
        RESULT_VARIABLE _GIT_REV_PARSE_RESULT
        OUTPUT_QUIET ERROR_QUIET
    )

    if (_GIT_REV_PARSE_RESULT EQUAL 0)
        set("_GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}" YES)
    else ()
        set("_GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}" NO)
    endif ()

    set(
        "_GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}"
        "${_GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}}"
        CACHE
        INTERNAL
        "Is the directory \"${_GIT_VERSION_INFO_GIT_DIR}\" tracked in a Git repository?"
    )
endif ()

endblock ()

endmacro ()


#[[
This internal macro obtains the Git toplevel directory and calculates its
FNV-1a 64bit hash.

@param _GIT_VERSION_INFO_GIT_DIR: The requested directory to check.
@param _GIT_VERSION_INFO_GIT_DIR_HASH: The FNV-1a 64bit hash of the requested directory.
@param _GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}:
    Truthy, if the requested directory is tracked in a Git repository, falsy
    otherwise.
@return _GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_${_GIT_VERSION_INFO_GIT_DIR_HASH}:
    The FNV-1a 64bit hash of the Git toplevel directory.

Usage:

_git_version_info_toplevel_hash()
]]
macro(_git_version_info_toplevel_hash)

block (SCOPE_FOR VARIABLES)

if ("${_GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}}" AND NOT DEFINED "_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_${_GIT_VERSION_INFO_GIT_DIR_HASH}")
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" rev-parse --path-format=absolute --show-toplevel
        WORKING_DIRECTORY "${_GIT_VERSION_INFO_GIT_DIR}"
        OUTPUT_VARIABLE _GIT_TOPLEVEL
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    cmake_path(HASH _GIT_TOPLEVEL "_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_${_GIT_VERSION_INFO_GIT_DIR_HASH}")

    set(
        "_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_${_GIT_VERSION_INFO_GIT_DIR_HASH}"
        "${_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_${_GIT_VERSION_INFO_GIT_DIR_HASH}}"
        CACHE
        INTERNAL
        "FNV-1a 64bit hash of the Git toplevel directory \"${_GIT_TOPLEVEL}\" to the directory \"${_GIT_VERSION_INFO_GIT_DIR}\"."
    )
endif ()

endblock ()

endmacro ()

#[[
This internal macro sets the file names for the generated files and generates
an initial version of the files.

@param _GIT_VERSION_INFO_GIT_DIR_HASH: The FNV-1a 64bit hash of the requested directory.
@param _GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}:
    Truthy, if the requested directory is tracked in a Git repository, falsy
    otherwise.
@param _GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_${_GIT_VERSION_INFO_GIT_DIR_HASH}:
    The FNV-1a 64bit hash of the Git toplevel directory.
@return
    - _GIT_VERSION_INFO_STATE_FILE: File path of the state file.
    - _GIT_VERSION_INFO_HEAD_SHA1_FILE: File path of the HEAD SHA1 file.

Usage:

_git_version_info_file_names()
]]
macro(_git_version_info_file_names)

block (
    SCOPE_FOR VARIABLES
    PROPAGATE
    _GIT_VERSION_INFO_STATE_FILE
    _GIT_VERSION_INFO_STATE_TMP_FILE
    _GIT_VERSION_INFO_HEAD_SHA1_FILE
    _GIT_VERSION_INFO_HEAD_SHA1_TMP_FILE
)

if ("${_GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}}")
    set(_GIT_TOPLEVEL_HASH "${_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_${_GIT_VERSION_INFO_GIT_DIR_HASH}}")
    set(_GIT_VERSION_INFO_STATE_FILE "${CMAKE_CURRENT_BINARY_DIR}/_git_version_info_state_${_GIT_TOPLEVEL_HASH}.txt")
    set(_GIT_VERSION_INFO_STATE_TMP_FILE "${CMAKE_CURRENT_BINARY_DIR}/_git_version_info_${_GIT_TOPLEVEL_HASH}_tmp.txt")
    set(_GIT_VERSION_INFO_HEAD_SHA1_FILE "${CMAKE_CURRENT_BINARY_DIR}/_git_version_info_head_sha1_${_GIT_TOPLEVEL_HASH}.txt")
    set(_GIT_VERSION_INFO_HEAD_SHA1_TMP_FILE "${CMAKE_CURRENT_BINARY_DIR}/_git_version_info_head_sha1_${_GIT_TOPLEVEL_HASH}_tmp.txt")

    if (NOT EXISTS "${_GIT_VERSION_INFO_STATE_FILE}")
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" describe --all --long --always --dirty
            WORKING_DIRECTORY "${_GIT_VERSION_INFO_GIT_DIR}"
            OUTPUT_FILE "${_GIT_VERSION_INFO_STATE_TMP_FILE}"
            COMMAND_ECHO STDOUT
        )

        execute_process(
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${_GIT_VERSION_INFO_STATE_TMP_FILE}" "${_GIT_VERSION_INFO_STATE_FILE}"
            OUTPUT_QUIET
        )

        execute_process(
            COMMAND "${CMAKE_COMMAND}" -E rm "${_GIT_VERSION_INFO_STATE_TMP_FILE}"
            OUTPUT_QUIET
        )
    endif ()

    if (NOT EXISTS "${_GIT_VERSION_INFO_HEAD_SHA1_FILE}")
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" rev-parse HEAD
            WORKING_DIRECTORY "${_GIT_VERSION_INFO_GIT_DIR}"
            OUTPUT_FILE "${_GIT_VERSION_INFO_HEAD_SHA1_TMP_FILE}"
            COMMAND_ECHO STDOUT
        )

        execute_process(
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${_GIT_VERSION_INFO_HEAD_SHA1_TMP_FILE}" "${_GIT_VERSION_INFO_HEAD_SHA1_FILE}"
            OUTPUT_QUIET
        )

        execute_process(
            COMMAND "${CMAKE_COMMAND}" -E rm "${_GIT_VERSION_INFO_HEAD_SHA1_TMP_FILE}"
            OUTPUT_QUIET
        )
    endif ()
endif ()

endblock ()

endmacro()


#[[
This macro writes a boolean flag into the user-provided variable name. It's
truthy, if the requested directory is tracked in a Git repository and falsy
otherwise.

@param The user-provided result variable name.
@param [GIT_DIR]: The requested directory or CMAKE_CURRENT_SOURCE_DIR.

Usage:

git_version_info_is_tracked_by_git(
    <result variable name>
    [GIT_DIR <path>]
)
]]
macro (git_version_info_is_tracked_by_git _RESULT_VARIABLE_NAME)

block (SCOPE_FOR VARIABLES PROPAGATE "${_RESULT_VARIABLE_NAME}")

cmake_parse_arguments(_GIT_VERSION_INFO "" "GIT_DIR" "" ${ARGN})
# _GIT_VERSION_INFO_GIT_DIR is now available.

_git_version_info_set_up()
_git_version_info_check()

set("${_RESULT_VARIABLE_NAME}" "${_GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}}")

endblock ()

endmacro ()

#[[
This macro writes the file path of the state file into the user-provided
variable name. If the requested directory is not tracked by Git, the result
variable is undefined.

@param The user-provided result variable name.
@param [GIT_DIR]: The requested directory or CMAKE_CURRENT_SOURCE_DIR.

Usage:

git_version_info_get_state_file_path(
    <result variable name>
    [GIT_DIR <path>]
)
]]
macro (git_version_info_get_state_file_path _RESULT_VARIABLE_NAME)

block (SCOPE_FOR VARIABLES PROPAGATE "${_RESULT_VARIABLE_NAME}")

cmake_parse_arguments(_GIT_VERSION_INFO "" "GIT_DIR" "" ${ARGN})
# _GIT_VERSION_INFO_GIT_DIR is now available.

_git_version_info_set_up()
_git_version_info_check()
_git_version_info_toplevel_hash()
_git_version_info_file_names()

if (DEFINED _GIT_VERSION_INFO_STATE_FILE)
    set("${_RESULT_VARIABLE_NAME}" "${_GIT_VERSION_INFO_STATE_FILE}")
endif ()

endblock ()

endmacro ()

#[[
This macro writes the file path of the HEAD SHA1 file into the user-provided
variable name. If the requested directory is not tracked by Git, the result
variable is undefined.

@param The user-provided result variable name.
@param [GIT_DIR]: The requested directory or CMAKE_CURRENT_SOURCE_DIR.

Usage:

git_version_info_get_head_sha1_file_path(
    <result variable name>
    [GIT_DIR <path>]
)
]]
macro (git_version_info_get_head_sha1_file_path _RESULT_VARIABLE_NAME)

block (SCOPE_FOR VARIABLES PROPAGATE "${_RESULT_VARIABLE_NAME}")

cmake_parse_arguments(_GIT_VERSION_INFO "" "GIT_DIR" "" ${ARGN})
# _GIT_VERSION_INFO_GIT_DIR is now available.

_git_version_info_set_up()
_git_version_info_check()
_git_version_info_toplevel_hash()
_git_version_info_file_names()

if (DEFINED _GIT_VERSION_INFO_HEAD_SHA1_FILE)
    set("${_RESULT_VARIABLE_NAME}" "${_GIT_VERSION_INFO_HEAD_SHA1_FILE}")
endif ()

endblock ()

endmacro ()

#[[
This macro creates a custom trigger target specific for this Git toplevel
directory, which triggers a rebuild whenever the HEAD commit or the dirty
state of the working directory changes and obtains the new git SHA1 hash for
HEAD. The user-provided target gains a target-level dependency on the custom
trigger target. All provided source files in the directory of the
user-provided target gain a file-level dependency on the custom trigger
target's byproduct and the SHA1 hash file. The user-provided target can be a
library, executable or custom target. The source files can be project source
files or source files generated by a custom command.

@param [GIT_DIR]: The requested directory or CMAKE_CURRENT_SOURCE_DIR.
@param TARGET: Name of the target that needs to be rebuilt.
@param SOURCES: List of source files that need to be rebuilt.

Usage:

git_version_info_add_dependant_source_files(
    [GIT_DIR <path>]
    TARGET <target>
    SOURCES <source file>...
)
]]
macro(git_version_info_add_dependant_source_files)

block (SCOPE_FOR VARIABLES)

cmake_parse_arguments(_GIT_VERSION_INFO "" "GIT_DIR;TARGET" "SOURCES" ${ARGN})
# _GIT_VERSION_INFO_GIT_DIR, _GIT_VERSION_INFO_TARGET and
# _GIT_VERSION_INFO_SOURCES are now available.

_git_version_info_set_up()
_git_version_info_check()
_git_version_info_toplevel_hash()
_git_version_info_file_names()

if ("${_GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}}")
    set(_GIT_TOPLEVEL_HASH "${_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_${_GIT_VERSION_INFO_GIT_DIR_HASH}}")

    if (NOT TARGET "_GIT_VERSION_INFO_TRIGGER_${_GIT_TOPLEVEL_HASH}")
        add_custom_target(
            "_GIT_VERSION_INFO_TRIGGER_${_GIT_TOPLEVEL_HASH}"
            COMMAND "${GIT_EXECUTABLE}" describe --all --long --always --dirty > "${_GIT_VERSION_INFO_STATE_TMP_FILE}"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${_GIT_VERSION_INFO_STATE_TMP_FILE}" "${_GIT_VERSION_INFO_STATE_FILE}"
            COMMAND "${CMAKE_COMMAND}" -E rm "${_GIT_VERSION_INFO_STATE_TMP_FILE}"
            BYPRODUCTS "${_GIT_VERSION_INFO_STATE_FILE}"
            WORKING_DIRECTORY "${_GIT_VERSION_INFO_GIT_DIR}"
            VERBATIM
        )

        add_custom_command(
            OUTPUT "${_GIT_VERSION_INFO_HEAD_SHA1_FILE}"
            DEPENDS "${_GIT_VERSION_INFO_STATE_FILE}"
            COMMAND "${GIT_EXECUTABLE}" rev-parse HEAD > "${_GIT_VERSION_INFO_HEAD_SHA1_TMP_FILE}"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${_GIT_VERSION_INFO_HEAD_SHA1_TMP_FILE}" "${_GIT_VERSION_INFO_HEAD_SHA1_FILE}"
            COMMAND "${CMAKE_COMMAND}" -E rm "${_GIT_VERSION_INFO_HEAD_SHA1_TMP_FILE}"
            WORKING_DIRECTORY "${_GIT_VERSION_INFO_GIT_DIR}"
            VERBATIM
        )
    endif ()

    add_dependencies("${_GIT_VERSION_INFO_TARGET}" "_GIT_VERSION_INFO_TRIGGER_${_GIT_TOPLEVEL_HASH}")

    foreach(_GIT_VERSION_INFO_SOURCE IN LISTS _GIT_VERSION_INFO_SOURCES)
        get_source_file_property(
            _GIT_VERSION_INFO_SOURCE_GENERATED
            "${_GIT_VERSION_INFO_SOURCE}"
            TARGET_DIRECTORY "${_GIT_VERSION_INFO_TARGET}"
            GENERATED
        )

        if (_GIT_VERSION_INFO_SOURCE_GENERATED)
            add_custom_command(OUTPUT "${_GIT_VERSION_INFO_SOURCE}" DEPENDS "${_GIT_VERSION_INFO_STATE_FILE}" "${_GIT_VERSION_INFO_HEAD_SHA1_FILE}" APPEND)
        else ()
            get_source_file_property(
                _GIT_VERSION_INFO_SOURCE_DEPENDENCIES
                "${_GIT_VERSION_INFO_SOURCE}"
                TARGET_DIRECTORY "${_GIT_VERSION_INFO_TARGET}"
                OBJECT_DEPENDS
            )

            if (_GIT_VERSION_INFO_SOURCE_DEPENDENCIES STREQUAL "NOTFOUND")
                set(_GIT_VERSION_INFO_SOURCE_DEPENDENCIES "")
            endif ()

            list(APPEND _GIT_VERSION_INFO_SOURCE_DEPENDENCIES "${_GIT_VERSION_INFO_STATE_FILE}" "${_GIT_VERSION_INFO_HEAD_SHA1_FILE}")

            set_source_files_properties(
                "${_GIT_VERSION_INFO_SOURCE}"
                TARGET_DIRECTORY "${_GIT_VERSION_INFO_TARGET}"
                PROPERTIES
                OBJECT_DEPENDS
                "${_GIT_VERSION_INFO_SOURCE_DEPENDENCIES}"
            )
        endif ()
    endforeach()
endif ()

endblock ()

endmacro ()


#[[
This macro obtains the new git SHA1 hash for HEAD whenever the HEAD commit or
the dirty state of the working directory changes. It writes the SHA1 into a
user-provided preprocessor variable in a header file and force includes it for
all provided sources. The user-provided target can be a library, executable or
custom target. The source files can be project source files or source files
generated by a custom command. But they must be compiled.

@param [GIT_DIR]: The requested directory or CMAKE_CURRENT_SOURCE_DIR.
@param TARGET: Name of the target that needs the SHA1 hash header file.
@param PREPROCESSOR_VAR: Name of the preprocessor variable to use for the SHA1 hash.
@param SOURCES: List of source files to compile with the SHA1 hash header file.

Usage:

git_version_info_add_compile_definitions(
    [GIT_DIR <path>]
    TARGET <target>
    PREPROCESSOR_VAR <preprocessor variable name>
    SOURCES <source file>...
)
]]
macro(git_version_info_add_compile_definitions)

block (SCOPE_FOR VARIABLES)

cmake_parse_arguments(_GIT_VERSION_INFO "" "GIT_DIR;TARGET;PREPROCESSOR_VAR" "SOURCES" ${ARGN})
# _GIT_VERSION_INFO_GIT_DIR, _GIT_VERSION_INFO_TARGET,
# _GIT_VERSION_INFO_PREPROCESSOR_VAR and _GIT_VERSION_INFO_SOURCES are now
# available.

_git_version_info_set_up()
_git_version_info_check()
_git_version_info_toplevel_hash()
_git_version_info_file_names()

if ("${_GIT_VERSION_INFO_TRACKED_BY_GIT_${_GIT_VERSION_INFO_GIT_DIR_HASH}}")
    set(_GIT_TOPLEVEL_HASH "${_GIT_VERSION_INFO_GIT_TOPLEVEL_HASH_${_GIT_VERSION_INFO_GIT_DIR_HASH}}")

    cmake_path(HASH _GIT_VERSION_INFO_PREPROCESSOR_VAR _GIT_VERSION_INFO_PREPROCESSOR_VAR_HASH)
    set(_GIT_VERSION_INFO_GENERATE_HEADER_TARGET "_GIT_VERSION_INFO_GENERATE_HEADER_${_GIT_TOPLEVEL_HASH}_${_GIT_VERSION_INFO_PREPROCESSOR_VAR_HASH}")

    set(_GIT_VERSION_INFO_HEADER_FILE "_git_version_info_head_sha1_${_GIT_TOPLEVEL_HASH}_${_GIT_VERSION_INFO_PREPROCESSOR_VAR_HASH}.h")
    set(_GIT_VERSION_INFO_HEADER_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/${_GIT_VERSION_INFO_HEADER_FILE}")

    if (NOT TARGET "${_GIT_VERSION_INFO_GENERATE_HEADER_TARGET}")
        set(_GIT_VERSION_INFO_GENERATE_HEADER_SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/_git_version_info_generate_header_${_GIT_TOPLEVEL_HASH}_${_GIT_VERSION_INFO_PREPROCESSOR_VAR_HASH}.cmake")

        file(
            CONFIGURE
            OUTPUT "${_GIT_VERSION_INFO_GENERATE_HEADER_SCRIPT}"
            CONTENT "\
file(STRINGS \"${_GIT_VERSION_INFO_HEAD_SHA1_FILE}\" _GIT_VERSION_INFO_HEAD_SHA1 LIMIT_COUNT 1)
file(CONFIGURE OUTPUT \"${_GIT_VERSION_INFO_HEADER_FILE_PATH}\" CONTENT \"#define ${_GIT_VERSION_INFO_PREPROCESSOR_VAR} \\\"\${_GIT_VERSION_INFO_HEAD_SHA1}\\\"\\n\")
"
            @ONLY
        )

        add_custom_command(
            OUTPUT "${_GIT_VERSION_INFO_HEADER_FILE_PATH}"
            DEPENDS "${_GIT_VERSION_INFO_GENERATE_HEADER_SCRIPT}"
            COMMAND "${CMAKE_COMMAND}" -P "${_GIT_VERSION_INFO_GENERATE_HEADER_SCRIPT}"
            VERBATIM
        )

        add_custom_target(
            "${_GIT_VERSION_INFO_GENERATE_HEADER_TARGET}"
            DEPENDS "${_GIT_VERSION_INFO_HEADER_FILE_PATH}"
        )

        git_version_info_add_dependant_source_files(
            GIT_DIR "${_GIT_VERSION_INFO_GIT_DIR}"
            TARGET "${_GIT_VERSION_INFO_GENERATE_HEADER_TARGET}"
            SOURCES "${_GIT_VERSION_INFO_HEADER_FILE_PATH}"
        )
    endif ()

    add_dependencies("${_GIT_VERSION_INFO_TARGET}" "${_GIT_VERSION_INFO_GENERATE_HEADER_TARGET}")

    set_source_files_properties(
        ${_GIT_VERSION_INFO_SOURCES}
        TARGET_DIRECTORY "${_GIT_VERSION_INFO_TARGET}"
        PROPERTIES
        COMPILE_OPTIONS
        "-include;${_GIT_VERSION_INFO_HEADER_FILE}"
        INCLUDE_DIRECTORIES
        "${CMAKE_CURRENT_BINARY_DIR}"
    )
endif ()

endblock ()

endmacro()
