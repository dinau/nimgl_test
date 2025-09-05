# Package

version       = "0.9.1"
author        = "dinau"
description   = "nimgl test program with file open dialog"
license       = "MIT"
srcDir        = "src"
bin           = @["nimgl_test"]

# Dependencies

requires "nimgl >= 1.0.0"
requires "https://github.com/dinau/nimgl-imgui == 1.89.9.6"
requires "implot == 0.16.8"
requires "tinydialogs"
requires "nim >= 1.6.20"


import strformat

#----------
# buildSrc
#----------
proc buildSrc(TARGET:string) =
  exec(fmt"nim cpp examples/{TARGET}/{TARGET}.nim")
  withDir(fmt"examples/{TARGET}"):
    exec(fmt"{TARGET}")

#----------
# tasks
#----------
task party,"ImDrawList Party Demo":
  buildSrc("imDrawListParty")

task jpfont,"Show JP font Demo":
  buildSrc("jpfont")

task implot,"Show JP ImPlot Demo":
  buildSrc("implot_jp")
