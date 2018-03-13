# stop if cmake version below 3.5
cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

# project name and supported languages
project(example Fortran C CXX)

# project version
set(VERSION_MAJOR 1)
set(VERSION_MINOR 0)
set(VERSION_PATCH 0)

# guard against in-source builds and bad build-type strings
include(cmake/safeguards.cmake)

# detect operating system and host processor
message(STATUS "We are on a ${CMAKE_SYSTEM_NAME} system")
message(STATUS "The host processor is ${CMAKE_HOST_SYSTEM_PROCESSOR}")

# place binaries and libraries according to GNU standards
include(GNUInstallDirs)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})

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
include(cmake/git_revision.cmake)

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

# set cdash buildname
set(BUILDNAME
    "${CMAKE_SYSTEM_NAME}-${CMAKE_HOST_SYSTEM_PROCESSOR}-${CMAKE_Fortran_COMPILER_ID}-${cmake_build_type_tolower}"
    CACHE STRING
    "Name of build on the dashboard"
    )

# allow to report to a cdash dashboard
include(CTest)

# fetch googletest
include(cmake/googletest.cmake)
fetch_googletest()

# enable testing
enable_testing()

# define tests
add_subdirectory(test)

# install target
include(cmake/install_target.cmake)

# cpack
include(cmake/packaging.cmake)
