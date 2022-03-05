# Package

version       = "0.1.0"
author        = "a4318"
description   = "thin wrapper for the zopflipng library for windows"
license       = "MIT"
srcDir        = "src"
skipDirs      = @["src/zopfli"]
# Dependencies

requires "nim >= 1.6.4"

# use static liblary
before install:
  cd("src/zopfli")
  exec("git submodule update --init")
  exec("gcc -c src/zopfli/blocksplitter.c src/zopfli/cache.c src/zopfli/deflate.c src/zopfli/gzip_container.c src/zopfli/hash.c src/zopfli/katajainen.c src/zopfli/lz77.c src/zopfli/squeeze.c src/zopfli/tree.c src/zopfli/util.c src/zopfli/zlib_container.c src/zopfli/zopfli_lib.c src/zopflipng/zopflipng_lib.cc src/zopflipng/lodepng/lodepng.cpp src/zopflipng/lodepng/lodepng_util.cpp -O2 -W -Wall -Wextra -Wno-unused-function -ansi -pedantic")
  exec("ar rc libzopflipng.a blocksplitter.o cache.o deflate.o gzip_container.o hash.o katajainen.o lz77.o squeeze.o tree.o util.o zlib_container.o zopfli_lib.o zopflipng_lib.o lodepng.o lodepng_util.o")
  cpFile("libzopflipng.a","../libzopflipng.dll")

#[
# use dll
before install:
  cd("src/zopfli")
  exec("git submodule update --init")
  mkDir("build")
  cd("build")
  exec("""cmake .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DZOPFLI_BUILD_SHARED=ON""")
  exec("cmake --build .")
  cpFile("libzopflipng.dll","../../libzopflipng.dll")
  cpFile("libzopfli.dll","../../libzopfli.dll")
]#
