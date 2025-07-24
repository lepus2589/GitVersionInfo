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

add_test(
    NAME test-repository-setup
    COMMAND
    "${CMAKE_COMMAND}"
    -D CMAKE_MINIMUM_REQUIRED_VERSION=${CMAKE_MINIMUM_REQUIRED_VERSION}
    -D CMAKE_MAXIMUM_SUPPORTED_VERSION=${CMAKE_MAXIMUM_SUPPORTED_VERSION}
    -D "TEST_CASE=test-repository-setup"
    -P "./helpers/test_case_wrapper.cmake"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

set_tests_properties(test-repository-setup PROPERTIES FIXTURES_SETUP WITH_REPOSITORY)

add_test(
    NAME test-repository-cleanup
    COMMAND
    "${CMAKE_COMMAND}"
    -D CMAKE_MINIMUM_REQUIRED_VERSION=${CMAKE_MINIMUM_REQUIRED_VERSION}
    -D CMAKE_MAXIMUM_SUPPORTED_VERSION=${CMAKE_MAXIMUM_SUPPORTED_VERSION}
    -D "TEST_CASE=test-repository-cleanup"
    -P "./helpers/test_case_wrapper.cmake"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

set_tests_properties(test-repository-cleanup PROPERTIES FIXTURES_CLEANUP WITH_REPOSITORY)

set(
    TEST_CASES_WITHOUT_REPOSITORY
    "check-for-git_test-case-01"
    "toplevel-hash_test-case-01"
)

set(
    TEST_CASES_WITH_REPOSITORY
    "check-for-git_test-case-02"
    "toplevel-hash_test-case-02"
    "add-dependants_test-case-01"
    "add-dependants_test-case-02"
    "add-compile-definitions_test-case-01"
    "add-compile-definitions_test-case-02"
)

set(
    TEST_CASES
    ${TEST_CASES_WITHOUT_REPOSITORY}
    ${TEST_CASES_WITH_REPOSITORY}
)
list(REMOVE_DUPLICATES TEST_CASES)

foreach (TEST_CASE IN LISTS TEST_CASES)
    if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${TEST_CASE}_setup.cmake")
        add_test(
            NAME "${TEST_CASE}_setup"
            COMMAND
            "${CMAKE_COMMAND}"
            -D CMAKE_MINIMUM_REQUIRED_VERSION=${CMAKE_MINIMUM_REQUIRED_VERSION}
            -D CMAKE_MAXIMUM_SUPPORTED_VERSION=${CMAKE_MAXIMUM_SUPPORTED_VERSION}
            -D "TEST_CASE=${TEST_CASE}_setup"
            -P "./helpers/test_case_wrapper.cmake"
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        )

        set_tests_properties("${TEST_CASE}_setup" PROPERTIES FIXTURES_SETUP "${TEST_CASE}" DEPENDS "test-repository-setup")
    endif ()

    if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${TEST_CASE}_cleanup.cmake")
        add_test(
            NAME "${TEST_CASE}_cleanup"
            COMMAND
            "${CMAKE_COMMAND}"
            -D CMAKE_MINIMUM_REQUIRED_VERSION=${CMAKE_MINIMUM_REQUIRED_VERSION}
            -D CMAKE_MAXIMUM_SUPPORTED_VERSION=${CMAKE_MAXIMUM_SUPPORTED_VERSION}
            -D "TEST_CASE=${TEST_CASE}_cleanup"
            -P "./helpers/test_case_wrapper.cmake"
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        )

        get_test_property(test-repository-cleanup DEPENDS REPOSITORY_CLEANUP_DEPENDS)
        list(APPEND REPOSITORY_CLEANUP_DEPENDS "${TEST_CASE}_cleanup")
        set_tests_properties(test-repository-cleanup PROPERTIES DEPENDS "${REPOSITORY_CLEANUP_DEPENDS}")
        set_tests_properties("${TEST_CASE}_cleanup" PROPERTIES FIXTURES_CLEANUP "${TEST_CASE}")
    endif ()

    add_test(
        NAME "${TEST_CASE}"
        COMMAND
        "${CMAKE_COMMAND}"
        -D CMAKE_MINIMUM_REQUIRED_VERSION=${CMAKE_MINIMUM_REQUIRED_VERSION}
        -D CMAKE_MAXIMUM_SUPPORTED_VERSION=${CMAKE_MAXIMUM_SUPPORTED_VERSION}
        -D "TEST_CASE=${TEST_CASE}"
        -P "./helpers/test_case_wrapper.cmake"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    )

    set(TEST_CASE_FIXTURES "${TEST_CASE}")

    if (TEST_CASE IN_LIST TEST_CASES_WITH_REPOSITORY)
        list(APPEND TEST_CASE_FIXTURES "WITH_REPOSITORY")
    endif ()

    set_tests_properties("${TEST_CASE}" PROPERTIES FIXTURES_REQUIRED "${TEST_CASE_FIXTURES}")
endforeach ()
