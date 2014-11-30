# set cdash buildname
set(BUILDNAME
    "${CMAKE_SYSTEM_NAME}-${CMAKE_HOST_SYSTEM_PROCESSOR}-${CMAKE_Fortran_COMPILER_ID}-${cmake_build_type_tolower}"
    CACHE STRING
    "Name of build on the dashboard"
    )

# activate ctest
include(CTest)
enable_testing()

# define a test
add_test(unit ${PROJECT_BINARY_DIR}/unit_tests)
