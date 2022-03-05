import os
import memfiles
import times
import strformat

type ZopfliPNGFilterStrategy* {.size: sizeof(cint).} = enum
  kStrategyZero = 0,
  kStrategyOne = 1,
  kStrategyTwo = 2,
  kStrategyThree = 3,
  kStrategyFour = 4,
  kStrategyMinSum,
  kStrategyEntropy,
  kStrategyPredefined,
  kStrategyBruteForce,
  kNumFilterStrategies #/* Not a strategy but used for the size of this enum */

type
  CZopfliPNGOptions* {.bycopy.} = object
    lossy_transparent: cint
    lossy_8bit: cint
    filter_strategies: ZopfliPNGFilterStrategy
    #// How many strategies to try.
    num_filter_strategies: cint
    auto_filter_strategy: cint
    keep_colortype: cint
    keepchunks: cstringArray
    #// How many entries in keepchunks.
    num_keepchunks: cint
    use_zopfli: cint
    num_iterations: cint
    num_iterations_large: cint
    block_split_strategy: cint

proc CZopfliPNGSetDefaults*(png_options: ptr CZopfliPNGOptions) {.importc.}

proc CZopfliPNGOptimize*(origpng: ptr uint8, origpng_size: uint, png_options: ptr CZopfliPNGOptions, verbose: cint, resultpng: ptr ptr uint8, resultpng_size: ptr uint) : cint {.importc.}


{.passL: currentSourcePath().parentDir() / "libzopflipng.a".}
{.passL: "-lstdc++ -static".}

proc optPngDef*(pngMem: MemFile, pngbuf: ptr uint8) : uint =
  let t = epochTime()
  var option = CZopfliPNGOptions()
  CZopfliPNGSetDefaults(option.addr)
  var outsize: uint
  let output = createU(uint8, 1)
  if CZopfliPNGOptimize(cast[ptr uint8](pngMem.mem), pngMem.size.uint, option.addr, 1, output.unsafeAddr, outsize.addr) != 0:
    return 0.uint
  copyMem(pngbuf, output, outsize)
  echo(fmt"reduce {(float)((pngMem.size - outsize.int)*100)/(float)pngMem.size}%: {epochTime() - t}")
  return outsize

proc optPngDef*(inpath, outpath: string) : bool {.discardable.} =
  let pngMem = memfiles.open(inpath)
  var output = createU(uint8, pngMem.size)
  let outsize = optPngDef(pngMem, output)
  if outsize == 0:
    dealloc output
    return false
  let f = io.open(outpath, fmWrite)
  if f.writeBuffer(output, outsize) != outsize.int:
    dealloc output
    return false
  f.close
  dealloc output
  return true
