#switch "passC","-std=c++17"
#
#switch "define", "release"
switch("define", "danger")
#
#switch "opt", "size"
#switch "passC","-O2"

#const LTO = true # further reudce code size
const LTO = false
when LTO:
  switch "passC", "-fno-strict-aliasing"
  switch "passL", "-fno-strict-aliasing"

if hostOS == "windows": # for static link
  switch "passC", "-static"
  switch "passL", "-static"
  # for c backend     https://github.com/nimgl/imgui/pull/9
  #switch "define","cimguiStaticCgcc"
  #switch "gcc.linkerexe","g++"

include "version.nims"
#
var TC = "gcc"
 #var TC = "clang"
 #var TC = "vcc"
 #var TC = "tcc"

if TC != "vcc":
  if "" == findExe(TC): # GCC is default compiler if TC dosn't exist on the PATH
    TC = "gcc"
  if "" == findExe(TC): # if dosn't exist gcc, try clang
    TC = "clang"

#switch "passL","-static-libgcc" # for 32bit Windows ?

# Reduce code size further
when false:
  #switch "mm","arc" # nim-1.6.8 or later
  switch "gc", "arc"
  switch "define", "useMalloc"
  switch "define", "noSignalHandler"
  #switch "panics","on"

#switch "verbosity","1"

proc commonOpt() =
  switch "passL", "-s"
  switch "passC", "-ffunction-sections"
  switch "passC", "-fdata-sections"
  switch "passL", "-Wl,--gc-sections"

#const NIMCACHE = ".nimcache_" & TC
switch "nimcache", ".nimcache"

case TC
  of "gcc":
    commonOpt()
    when LTO: # These options let link time slow while reducing code size.
      switch "passC", "-flto"
      switch "passL", "-flto"
  of "clang":
    commonOpt()
    #switch "passC","-flto=auto"
    #switch "passL","-flto"

switch "cc", TC

echo ""
echo "#### Compiler: [ ", TC, " ] ####"
echo ""


