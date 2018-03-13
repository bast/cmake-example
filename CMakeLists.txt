# stop if cmake version below 3.5
cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

# project name and supported languages
project(example Fortran C CXX)

# project version
set(VERSION_MAJOR 1)
set(VERSION_MINOR 0)
set(VERSION_PATCH 0)

# location of additional cmake modules
set(CMAKE_MODULE_PATH
    ${CMAKE_MODULE_PATH}
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake
    )

# guard against in-source builds and bad build-type strings
include(safeguards)

# detect operating system
message(STATUS "We are on a ${CMAKE_SYSTEM_NAME} system")
if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    add_definitions(-DSYSTEM_LINUX)
endif()
if(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    add_definitions(-DSYSTEM_DARWIN)
endif()
if(${CMAKE_SYSTEM_NAME} STREQUAL "AIX")
    add_definitions(-DSYSTEM_AIX)
endif()
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    add_definitions(-DSYSTEM_WINDOWS)
endif()

# detect host processor
message(STATUS "The host processor is ${CMAKE_HOST_SYSTEM_PROCESSOR}")

# example how to set c++ compiler flags for GNU
if(CMAKE_CXX_COMPILER_ID MATCHES GNU)
    set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -Wall -Wno-unknown-pragmas -Wno-sign-compare -Woverloaded-virtual -Wwrite-strings -Wno-unused")
    set(CMAKE_CXX_FLAGS_DEBUG   "-O0 -g3")
    set(CMAKE_CXX_FLAGS_RELEASE "-O3")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-arcs -ftest-coverage")
endif()

# build executable
add_executable(hello.x src/hello.F90)

# location of header files
include_directories(
    ${PROJECT_BINARY_DIR}
    ${PROJECT_SOURCE_DIR}/src
    )

# get git hash
include(git_revision)

# configure header file
configure_file(
    ${PROJECT_SOURCE_DIR}/cmake/config.h.in
    ${PROJECT_BINARY_DIR}/config.h
    )

# find python
find_package(PythonInterp)
if(NOT PYTHONINTERP_FOUND)
    message(FATAL_ERROR "ERROR: Python interpreter not found. Cannot continue - sorry.")
endif()

# generate the file
add_custom_target(
    generate_file
    COMMAND ${PYTHON_EXECUTABLE} ${PROJECT_SOURCE_DIR}/src/generate.py > ${PROJECT_BINARY_DIR}/mylib_generated.cpp
    )

# mark the file as generated
set_source_files_properties(${PROJECT_BINARY_DIR}/mylib_generated.cpp PROPERTIES GENERATED 1)

# static library
add_library(mylib_static STATIC src/mylib.cpp ${PROJECT_BINARY_DIR}/mylib_generated.cpp)
add_dependencies(mylib_static generate_file)

# shared library
add_library(mylib_shared SHARED src/mylib.cpp)

# compile main executable
add_executable(main.x src/main.cpp)

# link library
target_link_libraries(main.x mylib_static)

# library that holds sources to test
add_library(example src/example.cpp)

# target to update git submodules
add_custom_target(
    update_submodules
    COMMAND git submodule init
    COMMAND git submodule update
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

set(GOOGLETEST_ROOT external/googletest/googletest CACHE STRING "Google Test source root")

message(STATUS "GOOGLETEST_ROOT set to ${GOOGLETEST_ROOT}")

# google test includes
include_directories(
    ${PROJECT_SOURCE_DIR}/${GOOGLETEST_ROOT}
    ${PROJECT_SOURCE_DIR}/${GOOGLETEST_ROOT}/include
    )

# google test sources
set(GOOGLETEST_SOURCES
    ${PROJECT_SOURCE_DIR}/${GOOGLETEST_ROOT}/src/gtest-all.cc
    ${PROJECT_SOURCE_DIR}/${GOOGLETEST_ROOT}/src/gtest_main.cc
    )

# mark these files as generated (they may not be present at configure time)
foreach(_source ${GOOGLETEST_SOURCES})
    set_source_files_properties(${_source} PROPERTIES GENERATED 1)
endforeach()

add_library(googletest ${GOOGLETEST_SOURCES})

# update git submodules before building google test
add_dependencies(googletest update_submodules)

# unit test executable
add_executable(
    unit_tests
    test/main.cpp
    test/example_add.cpp
    test/example_subtract.cpp
    )

# unit test executable depends on google test
add_dependencies(unit_tests googletest)

# link unit test executable against google test
target_link_libraries(
    unit_tests
    googletest
    example
    pthread
    )

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

# make install and cpack
include(install_target)
