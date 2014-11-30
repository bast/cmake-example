#include <cstdio>

#include "mylib.h"
#include "config.h"

int main(int argc, char** argv)
{
    printf("program version: %i.%i.%i\n", VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH);

    do_something();
    do_something_else(); // generated
    return 0;
}
