# install binary
install(TARGETS main.x DESTINATION cmake-example/bin)

# install libs
install(TARGETS mylib_shared DESTINATION cmake-example/lib)
install(TARGETS mylib_static DESTINATION cmake-example/lib)

# install headers
install(FILES ${PROJECT_SOURCE_DIR}/src/mylib.h DESTINATION cmake-example/include)
