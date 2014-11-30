# stop if cmake version below 2.8
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

# project name
project(example)

# enable fortran, c, and c++ language
enable_language(Fortran C CXX)

# location of additional cmake modules
set(CMAKE_MODULE_PATH
    ${CMAKE_MODULE_PATH}
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake
    )

# guard against in-source builds and bad build-type strings
include(ConfigSafeGuards)

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

# build executable
add_executable(hello.x src/hello.F90)

# location of header files
include_directories(${PROJECT_SOURCE_DIR}/src)

# static library
add_library(mylib_static STATIC src/mylib.cpp)

# shared library
add_library(mylib_shared SHARED src/mylib.cpp)

# compile main executable
add_executable(main.x src/main.cpp)

# link library
target_link_libraries(main.x mylib_static)
