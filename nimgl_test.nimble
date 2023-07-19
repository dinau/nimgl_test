# Package

version       = "0.2.0"
author        = "dinau"
description   = "nimgl test program with file open dialog"
license       = "MIT"
srcDir        = "src"
bin           = @["nimgl_test"]

# Dependencies

requires "nimgl >= 1.0.0"
requires "https://github.com/dinau/nim-osdialog >= 0.1.4"  # req: nim-1.6.6 or later

let TARGET = "nimgl_test"

task clean,"clean":
    exec("rm -fr .nimcache")
    rmFile TARGET.toEXE()

