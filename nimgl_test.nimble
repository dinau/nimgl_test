# Package

version       = "0.4.0"
author        = "dinau"
description   = "nimgl test program with file open dialog"
license       = "MIT"
srcDir        = "src"
bin           = @["nimgl_test"]

# Dependencies

requires "nimgl >= 1.0.0"
requires "https://github.com/dinau/nimgl-imgui >= 1.89.8.3"
requires "https://github.com/dinau/nim-osdialog >= 0.1.4"  # req: nim-1.6.6 or later
requires "nim >= 1.6.6"

let TARGET = "nimgl_test"


task clean,"clean":
    exec("rm -fr .nimcache")
    rmFile TARGET.toEXE()

