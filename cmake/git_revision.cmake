find_package(Git)

if(GIT_FOUND)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-list --max-count=1 HEAD
        OUTPUT_VARIABLE GIT_REVISION
        ERROR_QUIET
        )
    if(NOT ${GIT_REVISION} STREQUAL "")
        string(STRIP ${GIT_REVISION} GIT_REVISION)
    endif()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} status -s
        OUTPUT_VARIABLE GIT_CHANGES
        ERROR_QUIET
        )
    if(NOT ${GIT_CHANGES} STREQUAL "")
        string(APPEND GIT_REVISION "-:UNCOMMITTED CHANGES")
        message("There are uncommited changes adjust .gitignore or commit: ${GIT_CHANGES}")
    endif()
    message(STATUS "Current git revision is ${GIT_REVISION}")
else()
    set(GIT_REVISION "unknown")
endif()
