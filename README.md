[![License](https://img.shields.io/badge/license-%20BSD--3-blue.svg)](../master/LICENSE)


# CMake example

Example project which demonstrates various CMake features.

- [CDash testing dashboard](http://my.cdash.org/index.php?project=cmake-example) (probably empty but you can submit your test result to it)


## How to build this demo

```
cmake -H. -Bbuild -DCMAKE_INSTALL_PREFIX:PATH=/tmp/foo
cd build
cmake --build .
ctest
cmake --build . --target install
```
