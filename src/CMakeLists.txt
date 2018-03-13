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
add_library(mylib_static STATIC mylib.cpp ${PROJECT_BINARY_DIR}/mylib_generated.cpp)
add_dependencies(mylib_static generate_file)
target_include_directories(
    mylib_static
    PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
    )

# shared library
add_library(mylib_shared SHARED mylib.cpp)

# compile main executable
add_executable(main.x main.cpp)
target_include_directories(
    main.x
    PRIVATE
        ${PROJECT_BINARY_DIR}
    )

# link library
target_link_libraries(main.x mylib_static)

# library that holds sources to test
add_library(example "")
target_sources(
    example
    PRIVATE
        example.cpp
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}/example.h
    )
target_include_directories(
    example
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}
    )

# install binary
install(TARGETS main.x DESTINATION cmake-example/bin)

# install libs
install(TARGETS mylib_shared DESTINATION cmake-example/lib)
install(TARGETS mylib_static DESTINATION cmake-example/lib)

# install headers
install(FILES ${PROJECT_SOURCE_DIR}/src/mylib.h DESTINATION cmake-example/include)
