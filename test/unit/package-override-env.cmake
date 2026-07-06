include(CMakePackageConfigHelpers)
include(${CPM_PATH}/testing.cmake)

set(TEST_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/project-override-env)

execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf ${TEST_BUILD_DIR})

configure_package_config_file(
  "${CMAKE_CURRENT_LIST_DIR}/local_dependency/OverrideCMakeLists.txt.in"
  "${CMAKE_CURRENT_LIST_DIR}/local_dependency/CMakeLists.txt"
  INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/junk
)

execute_process(
  COMMAND
    ${CMAKE_COMMAND} -E env
    "CPM_Dependency_SOURCE=${CMAKE_CURRENT_LIST_DIR}/local_dependency/dependency" ${CMAKE_COMMAND}
    "-S${CMAKE_CURRENT_LIST_DIR}/local_dependency" "-B${TEST_BUILD_DIR}"
  RESULT_VARIABLE ret
  ERROR_VARIABLE cmake_stderr
)

assert_equal(${ret} "0")

if(NOT "${cmake_stderr}" MATCHES "CPM:.*Dependency.*overridden by environment variable")
  message(FATAL_ERROR "Expected CPM ENV override warning not found in output:\n${cmake_stderr}")
else()
  message(STATUS "test passed: CPM ENV override warning was emitted")
endif()
